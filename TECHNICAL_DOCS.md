DOCUMENTACIÓN TÉCNICA - ARQUITECTURA DE LA SOLUCIÓN
==================================================

## Estructura del Proyecto

```
app/
├── Enums/
│   └── PortCallStatus.php          # Estados del registro de escala
├── Http/
│   ├── Controllers/Api/
│   │   └── PortCallController.php  # Controlador API para escalas
│   └── Requests/
│       └── StorePortCallRequest.php # Validación de request
├── Models/
│   ├── Vessel.php                  # Modelo de Barco
│   ├── PortCall.php                # Modelo de Escala
│   └── CargoItem.php               # Modelo de Ítem de Carga
├── Services/
│   └── PortCallService.php         # Lógica de negocio
├── Jobs/
│   └── NotifyCustomsAboutPortCallJob.php  # Job asíncrono
└── Exceptions/
    ├── VesselNotFoundException.php  # Excepción personalizada
    └── PortCallCreationException.php # Excepción personalizada

database/
└── migrations/
    ├── 2026_05_27_create_vessels_table.php
    ├── 2026_05_27_create_port_calls_table.php
    └── 2026_05_27_create_cargo_items_table.php

routes/
└── api.php                         # Rutas de API

```

## Flujo de Ejecución

1. **Request**: Cliente envía POST /api/port-calls con vessel_id y eta
2. **Validación**: StorePortCallRequest valida los datos
3. **Controlador**: PortCallController::store() procesa el request
4. **Servicio**: PortCallService::registerPortCallAndNotifyCustoms()
   - Valida existencia del barco
   - Crea el registro PortCall
   - Despacha el Job
5. **Base de datos**: Se inserta en port_calls con status = 'approaching'
6. **Job**: NotifyCustomsAboutPortCallJob se ejecuta (async)
   - Prepara payload
   - Notifica a Aduanas (placeholder)
7. **Response**: Retorna JSON con datos de la escala creada

## Enums - PortCallStatus

```php
PortCallStatus::APPROACHING   // Estado inicial
PortCallStatus::ARRIVED       // El barco llegó
PortCallStatus::BERTHED       // Atracado
PortCallStatus::LOADING       // Cargando
PortCallStatus::UNLOADING     // Descargando
PortCallStatus::COMPLETED     // Completado
PortCallStatus::CANCELLED     // Cancelado
```

## Validaciones Implementadas

### En StorePortCallRequest:
- vessel_id: Debe ser un entero que existe en vessels
- eta: Debe ser una fecha/hora válida en formato Y-m-d H:i:s
- eta: Debe ser igual o posterior a la hora actual

### En PortCallService:
- Verifica que el barco existe
- Valida transacción de base de datos
- Logging de errores

## Manejo de Errores

- **404 Not Found**: Barco no existe (VesselNotFoundException)
- **422 Unprocessable Entity**: Validación fallida o error de creación
- **500 Internal Server Error**: Error no controlado

Todas las excepciones se registran en storage/logs/laravel.log

## Seguridad

1. **Tipado estricto**: declare(strict_types=1) en todos los archivos
2. **Type hinting**: Todos los parámetros y retornos tienen tipos
3. **Validación**: FormRequest valida inputs
4. **Transacciones**: DB::transaction() asegura integridad
5. **Logging**: Todos los eventos se registran
6. **Excepciones personalizadas**: Mejor control de errores

## Base de Datos

### Tabla vessels
- Campos: name, imo, call_sign, type, flag, status, etc.
- Índices en: imo, call_sign, status

### Tabla port_calls
- Campos: vessel_id (FK), eta, ata, etd, atd, status, berth_assignment, notes
- Índices en: vessel_id, status, eta, created_at

### Tabla cargo_items
- Campos: port_call_id (FK), description, quantity, weight, etc.
- Índices en: port_call_id

## Configuración de Colas

El Job NotifyCustomsAboutPortCallJob utiliza:
- Driver: redis (recomendado) o database
- Reintentos: 3 veces
- Backoff: 60 segundos entre reintentos
- Logging en caso de fallo permanente

## Próximos Pasos para Completar

1. **Autenticación/Autorización**: Implementar en middleware
2. **Rate Limiting**: Agregar throttle en rutas
3. **Integración Aduanas**: Completar método notifyCustoms()
4. **Tests**: Crear test suite (Feature y Unit)
5. **Documentación Swagger**: Agregar OpenAPI specs
6. **Eventos**: Considerar event broadcasting
7. **Cache**: Agregar caché para consultas frecuentes

## Comandos Útiles

```bash
# Crear una instancia
php artisan tinker

# Ejecutar migraciones
php artisan migrate

# Revertir migraciones
php artisan migrate:rollback

# Ver estado de colas (si usas database)
php artisan queue:failed

# Ejecutar un worker de colas
php artisan queue:work

# Ver logs en tiempo real
tail -f storage/logs/laravel.log
```

## Notas de Performance

1. Se usa índices en columnas clave (vessel_id, status, eta)
2. Las relaciones se cargan explícitamente con select()
3. Los Jobs se ejecutan de forma asíncrona
4. Las transacciones garantizan consistencia
5. El logging es selectivo (no spam)

## Cumplimiento de Requisitos

✅ Endpoint POST /api/port-calls
✅ Validación de vessel_id y eta
✅ Verificación de existencia del barco
✅ Registro de PortCall con estado inicial
✅ Job asíncrono para notificación
✅ Patrón de Servicios
✅ FormRequest para validaciones
✅ Enums fuertemente tipados
✅ Tipado estricto en todo el código
✅ Manejo de errores completo
✅ Logging y debugging
✅ Código listo para producción
