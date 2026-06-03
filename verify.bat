@echo off
REM verify.bat - Script de verificacion de integridad del proyecto

setlocal enabledelayedexpansion

echo.
echo ======================================
echo VERIFICACION DE INTEGRIDAD
echo Sistema Portuario v1.0.0
echo ======================================
echo.

set TOTAL=0
set OK=0
set MISSING=0

REM Archivos requeridos
set ARCHIVOS[0]=README.md
set ARCHIVOS[1]=DELIVERY_SUMMARY.md
set ARCHIVOS[2]=TESTING_GUIDE.md
set ARCHIVOS[3]=QUEUE_CONFIGURATION.md
set ARCHIVOS[4]=TECHNICAL_DOCS.md
set ARCHIVOS[5]=PROJECT_STRUCTURE.md
set ARCHIVOS[6]=setup.bat
set ARCHIVOS[7]=app\Enums\PortCallStatus.php
set ARCHIVOS[8]=app\Http\Controllers\Api\PortCallController.php
set ARCHIVOS[9]=app\Http\Requests\StorePortCallRequest.php
set ARCHIVOS[10]=app\Models\Vessel.php
set ARCHIVOS[11]=app\Models\PortCall.php
set ARCHIVOS[12]=app\Models\CargoItem.php
set ARCHIVOS[13]=app\Services\PortCallService.php
set ARCHIVOS[14]=app\Jobs\NotifyCustomsAboutPortCallJob.php
set ARCHIVOS[15]=app\Exceptions\VesselNotFoundException.php
set ARCHIVOS[16]=app\Exceptions\PortCallCreationException.php
set ARCHIVOS[17]=database\migrations\2026_05_27_create_vessels_table.php
set ARCHIVOS[18]=database\migrations\2026_05_27_create_port_calls_table.php
set ARCHIVOS[19]=database\migrations\2026_05_27_create_cargo_items_table.php
set ARCHIVOS[20]=routes\api.php

echo [*] Verificando archivos requeridos...
echo.

for /l %%i in (0,1,20) do (
    set /a TOTAL+=1
    
    if exist "!ARCHIVOS[%%i]!" (
        echo [OK] !ARCHIVOS[%%i]!
        set /a OK+=1
    ) else (
        echo [XX] FALTA: !ARCHIVOS[%%i]!
        set /a MISSING+=1
    )
)

echo.
echo ======================================
echo RESULTADO DE VERIFICACION
echo ======================================
echo.
echo Total de archivos: %TOTAL%
echo Presentes:        %OK%
echo Faltantes:        %MISSING%
echo.

if %MISSING% equ 0 (
    echo [OK] ¡PROYECTO COMPLETO!
    echo.
    echo Proximos pasos:
    echo    1. Configura tu archivo .env
    echo    2. Ejecuta: setup.bat
    echo    3. Prueba el endpoint
    echo.
    echo Documentacion:
    echo    - Comienza con: README.md
    echo    - Pruebas: TESTING_GUIDE.md
    echo    - Tecnico: TECHNICAL_DOCS.md
    echo.
) else (
    echo [XX] ADVERTENCIA: Faltan %MISSING% archivos
    echo    Por favor, asegúrate de descargar/copiar todos los archivos
    echo.
)

pause
