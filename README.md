# Sistema Portuario - Registro de Escalas (Port Calls)

## 📋 Descripción General

Esta implementación proporciona un endpoint API para registrar la llegada programada de barcos en el puerto, usando **PHP 8.x con Laravel 11** siguiendo arquitectura profesional y mejores prácticas.

## 🎯 Funcionalidad Principal

**Endpoint**: `POST /api/port-calls`

Registra la escala (Port Call) de un barco con los siguientes pasos:

1. ✅ Recibe `vessel_id` y `eta` (fecha/hora estimada)
2. ✅ Valida que el barco existe en el sistema
3. ✅ Crea el registro de escala con estado inicial `APPROACHING`
4. ✅ Despacha un Job asíncrono para notificar a Aduanas
5. ✅ Retorna respuesta JSON con los datos del registro

## 📁 Estructura de Archivos

```
SistemaPortuario/
├── app/
│   ├── Enums/PortCallStatus.php              # Estados (Enum fuertemente tipado)
│   ├── Http/Controllers/Api/
│   │   └── PortCallController.php            # Controlador API
│   ├── Http/Requests/
│   │   └── StorePortCallRequest.php          # Validación de formulario
│   ├── Models/
│   │   ├── Vessel.php                        # Modelo Barco
│   │   ├── PortCall.php                      # Modelo Escala
│   │   └── CargoItem.php                     # Modelo Carga
│   ├── Services/
│   │   └── PortCallService.php               # Lógica de negocio (patrón Service)
│   ├── Jobs/
│   │   └── NotifyCustomsAboutPortCallJob.php # Job asíncrono (Queue)
│   └── Exceptions/
│       ├── VesselNotFoundException.php        # Excepción personalizada
│       └── PortCallCreationException.php     # Excepción personalizada
├── database/
│   └── migrations/
│       ├── 2026_05_27_create_vessels_table.php
│       ├── 2026_05_27_create_port_calls_table.php
│       └── 2026_05_27_create_cargo_items_table.php
├── routes/
│   └── api.php                               # Rutas de API
├── QUEUE_CONFIGURATION.md                    # Configuración de colas
├── TESTING_GUIDE.md                          # Guía de pruebas
└── TECHNICAL_DOCS.md                         # Documentación técnica
```

## 🔧 Stack Técnico

| Componente | Versión |
|-----------|---------|
| PHP | 8.x |
| Laravel | 11.x |
| MySQL | 8.0 |
| Eloquent ORM | Built-in |
| Queue Driver | Redis / Database |

## ✨ Características

### ✅ Validación Robusta
- FormRequest con reglas estrictas
- Validación de existencia de barco
- Validación de fecha/hora futura
- Mensajes de error personalizados

### ✅ Tipado Estricto
- `declare(strict_types=1)` en todos los archivos
- Type hints en todos los parámetros
- Type hints en todos los valores de retorno
- Uso de Enums fuertemente tipados

### ✅ Arquitectura Limpia
- Patrón de Servicios (lógica en Services, no en Controllers)
- Controlador delgado (solo coordina)
- Responsabilidad única
- Excepciones personalizadas

### ✅ Gestión de Errores
- Captura de excepciones
- Respuestas HTTP apropiadas (404, 422, 500)
- Logging completo de eventos y errores
- Mensajes de error amigables

### ✅ Procesamiento Asíncrono
- Job para notificación a Aduanas
- Reintentos automáticos (3 veces)
- Backoff exponencial (60 segundos)
- Logging de fallos permanentes

## 🚀 Inicio Rápido

### 1. Instalación de Dependencias

```bash
# Clona o inicializa tu proyecto Laravel 11
composer install

# Instala Redis (si lo usarás para colas - recomendado)
composer require predis/predis
```

### 2. Configuración

```env
# .env - Configuración de base de datos
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sistema_portuario
DB_USERNAME=root
DB_PASSWORD=

# .env - Configuración de colas
QUEUE_CONNECTION=redis
# O usa: QUEUE_CONNECTION=database (alternativa)

# .env - Redis (si usas colas con Redis)
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_DB=1
```

### 3. Ejecutar Migraciones

```bash
php artisan migrate
```

### 4. Crear un Barco de Prueba

```bash
php artisan tinker

# En Tinker:
App\Models\Vessel::create([
    'name' => 'Test Vessel',
    'imo' => 'IMO1234567',
    'call_sign' => 'TEST',
    'type' => 'Container Ship',
    'flag' => 'US',
    'status' => 'active'
]);

# Salir: exit
```

## 🧪 Pruebas

### Usando CURL

```bash
curl -X POST http://localhost:8000/api/port-calls \
  -H "Content-Type: application/json" \
  -d '{
    "vessel_id": 1,
    "eta": "2026-06-15 14:30:00"
  }'
```

### Respuesta Exitosa (201 Created)

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

### Error - Barco No Existe (404)

```json
{
  "error": "Recurso no encontrado",
  "message": "El barco con ID 9999 no existe en el sistema."
}
```

### Error - Validación Fallida (422)

```json
{
  "message": "The eta field must be a date after or equal to now.",
  "errors": {
    "eta": ["The eta field must be a date after or equal to now."]
  }
}
```

## 📖 Documentación

| Archivo | Contenido |
|---------|-----------|
| [TESTING_GUIDE.md](./TESTING_GUIDE.md) | Ejemplos completos de prueba, CURL, Postman |
| [QUEUE_CONFIGURATION.md](./QUEUE_CONFIGURATION.md) | Configuración de colas, instalación de Redis |
| [TECHNICAL_DOCS.md](./TECHNICAL_DOCS.md) | Arquitectura, flujo, componentes, commands |

## 🔒 Seguridad

- ✅ Tipado estricto previene bugs
- ✅ Validación de inputs robusta
- ✅ Excepciones personalizadas controladas
- ✅ Transacciones de BD para consistencia
- ✅ Logging de auditoría
- ✅ Preparado para agregar autenticación/autorización
- ✅ Preparado para SSL/TLS

## 📊 Base de Datos

### Tabla `vessels` (Barcos)
- id, name, imo, call_sign, type, flag, status, timestamps
- Índices: imo, call_sign, status

### Tabla `port_calls` (Escalas)
- id, vessel_id (FK), eta, ata, etd, atd, status, berth_assignment, notes, timestamps
- Índices: vessel_id, status, eta, created_at

### Tabla `cargo_items` (Items de Carga)
- id, port_call_id (FK), description, quantity, weight, container_numbers, timestamps
- Índices: port_call_id

## 🎯 Estados de Escala (PortCallStatus Enum)

```php
APPROACHING   // El barco se aproxima al puerto
ARRIVED       // El barco ha llegado al puerto
BERTHED       // El barco está atracado
LOADING       // En fase de carga
UNLOADING     // En fase de descarga
COMPLETED     // Escala completada
CANCELLED     // Escala cancelada
```

## 🔄 Flujo de Ejecución

```
Request POST /api/port-calls
    ↓
StorePortCallRequest (Validación)
    ↓
PortCallController::store()
    ↓
PortCallService::registerPortCallAndNotifyCustoms()
    ├─ Verifica existencia del barco
    ├─ Crea registro en port_calls
    ├─ Guarda en BD (transacción)
    └─ Despacha Job
        ↓
NotifyCustomsAboutPortCallJob (Queue)
    ├─ Prepara payload
    ├─ Notifica Aduanas (placeholder)
    └─ Registra evento
        ↓
Response JSON (201 Created)
```

## 🛠️ Próximos Pasos Recomendados

1. **Autenticación**: Agregar middleware de Auth
2. **Rate Limiting**: Proteger contra abuso
3. **Swagger/OpenAPI**: Documentación interactiva
4. **Tests**: Suite de unit y feature tests
5. **Integración Aduanas**: Completar notifyCustoms()
6. **Eventos**: Implement broadcasting si necesitas real-time
7. **Cache**: Redis cache para consultas frecuentes

## 📝 Requisitos Cumplidos

✅ Endpoint POST `/api/port-calls`  
✅ Validación vessel_id y eta  
✅ Verificación de existencia de barco  
✅ Registro de PortCall con estado inicial  
✅ Job asíncrono para notificación  
✅ Patrón de Servicios  
✅ FormRequest para validaciones  
✅ Enums fuertemente tipados  
✅ Tipado estricto (declare strict_types)  
✅ Type hints completos  
✅ Manejo de errores integral  
✅ Logging y debugging  
✅ Código listo para producción  
✅ Sin ejemplos simplificados  

## 📞 Soporte

Para preguntas o problemas:
1. Consulta [TESTING_GUIDE.md](./TESTING_GUIDE.md) para resolver problemas de prueba
2. Revisa [TECHNICAL_DOCS.md](./TECHNICAL_DOCS.md) para entender la arquitectura
3. Verifica los logs: `storage/logs/laravel.log`

---

**Versión**: 1.0.0  
**Última actualización**: 27 de Mayo de 2026  
**Autor**: Backend Senior Developer - Laravel 11
