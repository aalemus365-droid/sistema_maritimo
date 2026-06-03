CONFIGURACIÓN RECOMENDADA PARA COLAS (.env)
=============================================

# Configurar la cola predeterminada (Redis recomendado para producción)
QUEUE_CONNECTION=redis
# Alternativa para desarrollo: database o sync

# Configuración de Redis (si usas QUEUE_CONNECTION=redis)
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_DB=1

# Configuración alternativa con base de datos (si usas QUEUE_CONNECTION=database)
# (No requiere configuración adicional, pero menos eficiente)

INSTALACIÓN DE DEPENDENCIAS
============================

1. Si decides usar Redis como cola (RECOMENDADO para producción):

   composer require predis/predis

   Luego configura .env:
   QUEUE_CONNECTION=redis

2. Comandos para ejecutar las migraciones:

   php artisan migrate

3. Si deseas probar con colas sincrónicas (desarrollo):

   .env:
   QUEUE_CONNECTION=sync

4. Para ejecutar los jobs en producción (si usas Redis/Database):

   php artisan queue:work redis --queue=default --tries=3

CONFIGURACIÓN ADICIONAL EN config/queue.php
=============================================

Si necesitas ajustar la configuración de colas, verifica que el archivo config/queue.php 
contenga los drivers correctamente configurados. Ejemplo:

'redis' => [
    'driver' => 'redis',
    'connection' => 'default',
    'queue' => env('REDIS_QUEUE', 'default'),
    'retry_after' => 90,
    'block_for' => null,
],

MANEJO DE COLAS EN DESARROLLO
==============================

Para probar los jobs en tiempo real sin ejecutar queue:work, puedes:

1. Usar QUEUE_CONNECTION=sync en tu .env de desarrollo
   (Los jobs se ejecutarán de forma síncrona inmediatamente)

2. O ejecutar: php artisan queue:work --timeout=60

REGISTRAR LOS MODELOS EN LA TABLA jobs (si usas database)
=========================================================

Si usas QUEUE_CONNECTION=database, ejecuta:

php artisan queue:table
php artisan migrate
