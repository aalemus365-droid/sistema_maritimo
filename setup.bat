@echo off
REM setup.bat - Script de configuración rápida del Sistema Portuario (Windows)

echo.
echo ======================================
echo Sistema Portuario - Setup Rapido
echo ======================================
echo.

REM Verificar que estamos en la carpeta correcta
if not exist "artisan" (
    echo [X] Error: Este script debe ejecutarse desde la raiz del proyecto Laravel
    pause
    exit /b 1
)

echo [OK] Carpeta de proyecto verificada
echo.

REM 1. Instalar dependencias
echo [*] Instalando dependencias de Composer...
call composer install

echo.
echo [*] Instalando driver de Redis para colas...
call composer require predis/predis

echo.

REM 2. Configurar .env
echo [*] Configurando archivo .env...
if not exist ".env" (
    copy .env.example .env
    echo [OK] Archivo .env creado desde .env.example
) else (
    echo [OK] Archivo .env ya existe
)

echo.
echo [!] Verifica que tu .env contiene:
echo     - DB_CONNECTION=mysql
echo     - DB_DATABASE=sistema_portuario
echo     - QUEUE_CONNECTION=redis (o database)
echo.

REM 3. Generar APP_KEY
echo [*] Generando APP_KEY...
call php artisan key:generate

echo.

REM 4. Ejecutar migraciones
echo [*] Ejecutando migraciones...
call php artisan migrate

echo.

REM 5. Crear barco de prueba
echo [*] Creando barco de prueba...
@echo on
php artisan tinker <<EOF
App\Models\Vessel::create([
    'name' => 'Test Vessel',
    'imo' => 'IMO1234567',
    'call_sign' => 'TEST',
    'type' => 'Container Ship',
    'flag' => 'US',
    'status' => 'active'
]);
echo "\n[OK] Barco de prueba creado\n";
exit;
EOF
@echo off

echo.
echo ======================================
echo [OK] Setup completado exitosamente!
echo ======================================
echo.
echo [i] Proximos pasos:
echo.
echo 1. Inicia el servidor de desarrollo:
echo    php artisan serve
echo.
echo 2. En otra terminal, inicia el worker de colas (opcional):
echo    php artisan queue:work
echo.
echo 3. Prueba el endpoint:
echo    curl -X POST http://localhost:8000/api/port-calls ^
echo      -H "Content-Type: application/json" ^
echo      -d "{\"vessel_id\": 1, \"eta\": \"2026-06-15 14:30:00\"}"
echo.
echo [i] Para mas informacion, consulta:
echo     - README.md (Resumen general)
echo     - TESTING_GUIDE.md (Ejemplos de prueba)
echo     - TECHNICAL_DOCS.md (Documentacion tecnica)
echo.
pause
