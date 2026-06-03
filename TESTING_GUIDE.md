GUÍA DE PRUEBAS - ENDPOINT POST /api/port-calls
==============================================

## Requisitos previos

1. Asegúrate de tener Laravel 11 instalado y configurado
2. Base de datos MySQL 8.0 en marcha
3. Ejecuta las migraciones: php artisan migrate
4. Crea un registro de barco en la BD para las pruebas

## Insertar un barco de prueba en la base de datos

Ejecuta en tu terminal o Laravel Tinker:

```bash
php artisan tinker
```

Luego en Tinker:

```php
App\Models\Vessel::create([
    'name' => 'Test Vessel',
    'imo' => 'IMO1234567',
    'call_sign' => 'TEST',
    'type' => 'Container Ship',
    'flag' => 'US',
    'status' => 'active'
]);
```

O mediante SQL directo:

```sql
INSERT INTO vessels (name, imo, call_sign, type, flag, status, created_at, updated_at)
VALUES ('Test Vessel', 'IMO1234567', 'TEST', 'Container Ship', 'US', 'active', NOW(), NOW());
```

El ID del barco será 1 (si es el primero).

## Ejemplo 1: Petición CURL (Éxito)

```bash
curl -X POST http://localhost:8000/api/port-calls \
  -H "Content-Type: application/json" \
  -d '{
    "vessel_id": 1,
    "eta": "2026-06-15 14:30:00"
  }'
```

Respuesta esperada (201 Created):
```json
{
  "message": "Escala registrada exitosamente.",
  "data": {
    "id": 1,
    "vessel_id": 1,
    "vessel_name": "Test Vessel",
    "eta": "2026-06-15T14:30:00+00:00",
    "status": "approaching",
    "status_label": "Aproximándose",
    "created_at": "2026-05-27T12:34:56+00:00"
  }
}
```

## Ejemplo 2: Error - Barco no existe

```bash
curl -X POST http://localhost:8000/api/port-calls \
  -H "Content-Type: application/json" \
  -d '{
    "vessel_id": 9999,
    "eta": "2026-06-15 14:30:00"
  }'
```

Respuesta esperada (404 Not Found):
```json
{
  "error": "Recurso no encontrado",
  "message": "El barco con ID 9999 no existe en el sistema."
}
```

## Ejemplo 3: Error - Validación fallida (ETA en el pasado)

```bash
curl -X POST http://localhost:8000/api/port-calls \
  -H "Content-Type: application/json" \
  -d '{
    "vessel_id": 1,
    "eta": "2020-01-01 10:00:00"
  }'
```

Respuesta esperada (422 Unprocessable Entity):
```json
{
  "message": "The eta field must be a date after or equal to now. (and 1 more error)",
  "errors": {
    "eta": [
      "The eta field must be a date after or equal to now."
    ]
  }
}
```

## Ejemplo 4: Error - Campo requerido faltante

```bash
curl -X POST http://localhost:8000/api/port-calls \
  -H "Content-Type: application/json" \
  -d '{
    "vessel_id": 1
  }'
```

Respuesta esperada (422 Unprocessable Entity):
```json
{
  "message": "The eta field is required.",
  "errors": {
    "eta": [
      "The eta field is required."
    ]
  }
}
```

## Ejemplo 5: Usando Postman/Insomnia

Método: POST
URL: http://localhost:8000/api/port-calls
Headers:
  Content-Type: application/json
  Accept: application/json

Body (JSON):
{
  "vessel_id": 1,
  "eta": "2026-06-15 14:30:00"
}

## Verificar los logs generados

Los logs se almacenan en storage/logs/laravel.log

Comandos para verificar:

```bash
# Ver últimas líneas
tail -f storage/logs/laravel.log

# Ver logs en tiempo real (Linux/Mac)
tail -f storage/logs/laravel.log

# En Windows (PowerShell)
Get-Content storage/logs/laravel.log -Tail 50 -Wait
```

## Verificar el Job en la cola

Si configuraste Redis o Database como QUEUE_CONNECTION:

```bash
# Ver estado de los jobs
php artisan queue:failed

# Reintenta los jobs fallidos
php artisan queue:retry all

# Purga los jobs fallidos
php artisan queue:flush
```

## Verificar en la base de datos

```sql
-- Ver la escala creada
SELECT * FROM port_calls ORDER BY created_at DESC LIMIT 1;

-- Ver todas las escalas de un barco
SELECT * FROM port_calls WHERE vessel_id = 1;
```

## Troubleshooting

### Error: "The vessel specified does not exist"
- Verifica que existe el barco en la tabla vessels
- Usa correctamente el vessel_id

### Error: "The eta field must be a date after or equal to now"
- Asegúrate de que la fecha sea futura
- Usa el formato exacto: Y-m-d H:i:s

### Error: 500 Internal Server Error
- Revisa storage/logs/laravel.log para más detalles
- Verifica que la conexión a la BD está correcta

### Los Jobs no se ejecutan
- Verifica que QUEUE_CONNECTION está configurado
- Si usas redis, asegúrate de que Redis está en marcha
- Ejecuta: php artisan queue:work

## Notas de seguridad para producción

1. Agrega autenticación/autorización al controlador
2. Implementa rate limiting en la ruta
3. Configura CORS si es necesario
4. Valida y sanitiza siempre los inputs
5. Usa SSL/TLS (HTTPS)
6. Implementa la integración real con el sistema de Aduanas
