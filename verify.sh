#!/bin/bash
# verify.sh - Script de verificación de integridad del proyecto

echo "======================================"
echo "VERIFICACIÓN DE INTEGRIDAD"
echo "Sistema Portuario v1.0.0"
echo "======================================"
echo ""

TOTAL=0
OK=0
MISSING=0

# Arrays de archivos requeridos
ARCHIVOS=(
    "README.md"
    "DELIVERY_SUMMARY.md"
    "TESTING_GUIDE.md"
    "QUEUE_CONFIGURATION.md"
    "TECHNICAL_DOCS.md"
    "PROJECT_STRUCTURE.md"
    "setup.sh"
    "setup.bat"
    "app/Enums/PortCallStatus.php"
    "app/Http/Controllers/Api/PortCallController.php"
    "app/Http/Requests/StorePortCallRequest.php"
    "app/Models/Vessel.php"
    "app/Models/PortCall.php"
    "app/Models/CargoItem.php"
    "app/Services/PortCallService.php"
    "app/Jobs/NotifyCustomsAboutPortCallJob.php"
    "app/Exceptions/VesselNotFoundException.php"
    "app/Exceptions/PortCallCreationException.php"
    "database/migrations/2026_05_27_create_vessels_table.php"
    "database/migrations/2026_05_27_create_port_calls_table.php"
    "database/migrations/2026_05_27_create_cargo_items_table.php"
    "routes/api.php"
)

echo "📋 Verificando archivos requeridos..."
echo ""

for archivo in "${ARCHIVOS[@]}"; do
    TOTAL=$((TOTAL + 1))
    
    if [ -f "$archivo" ]; then
        echo "✅ $archivo"
        OK=$((OK + 1))
    else
        echo "❌ FALTA: $archivo"
        MISSING=$((MISSING + 1))
    fi
done

echo ""
echo "======================================"
echo "RESULTADO DE VERIFICACIÓN"
echo "======================================"
echo ""
echo "Total de archivos: $TOTAL"
echo "Presentes:        $OK"
echo "Faltantes:        $MISSING"
echo ""

if [ $MISSING -eq 0 ]; then
    echo "✅ ¡PROYECTO COMPLETO!"
    echo ""
    echo "📝 Próximos pasos:"
    echo "   1. Configura tu archivo .env"
    echo "   2. Ejecuta: bash setup.sh"
    echo "   3. Prueba el endpoint"
    echo ""
    echo "📖 Documentación:"
    echo "   - Comienza con: README.md"
    echo "   - Pruebas: TESTING_GUIDE.md"
    echo "   - Técnico: TECHNICAL_DOCS.md"
    exit 0
else
    echo "❌ ADVERTENCIA: Faltan $MISSING archivos"
    echo "   Por favor, asegúrate de descargar/copiar todos los archivos"
    exit 1
fi
