#!/bin/bash
# setup.sh - Script de configuración rápida del Sistema Portuario

echo "======================================"
echo "Sistema Portuario - Setup Rápido"
echo "======================================"
echo ""

# Verificar que estamos en la carpeta correcta
if [ ! -f "artisan" ]; then
    echo "❌ Error: Este script debe ejecutarse desde la raíz del proyecto Laravel"
    exit 1
fi

echo "✅ Carpeta de proyecto verificada"
echo ""

# 1. Instalar dependencias
echo "📦 Instalando dependencias de Composer..."
composer install

echo ""
echo "🔴 Instalando driver de Redis para colas..."
composer require predis/predis

echo ""

# 2. Configurar .env
echo "⚙️  Configurando archivo .env..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ Archivo .env creado desde .env.example"
else
    echo "✅ Archivo .env ya existe"
fi

echo ""
echo "📝 Verifica que tu .env contiene:"
echo "   - DB_CONNECTION=mysql"
echo "   - DB_DATABASE=sistema_portuario"
echo "   - QUEUE_CONNECTION=redis (o database)"
echo ""

# 3. Generar APP_KEY
echo "🔑 Generando APP_KEY..."
php artisan key:generate

echo ""

# 4. Ejecutar migraciones
echo "🗄️  Ejecutando migraciones..."
php artisan migrate

echo ""

# 5. Crear barco de prueba
echo "🚢 Creando barco de prueba..."
php artisan tinker << 'EOF'
App\Models\Vessel::create([
    'name' => 'Test Vessel',
    'imo' => 'IMO1234567',
    'call_sign' => 'TEST',
    'type' => 'Container Ship',
    'flag' => 'US',
    'status' => 'active'
]);
echo "\n✅ Barco de prueba creado\n";
exit;
EOF

echo ""
echo "======================================"
echo "✅ Setup completado exitosamente!"
echo "======================================"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1. Inicia el servidor de desarrollo:"
echo "   php artisan serve"
echo ""
echo "2. En otra terminal, inicia el worker de colas (opcional):"
echo "   php artisan queue:work"
echo ""
echo "3. Prueba el endpoint:"
echo "   curl -X POST http://localhost:8000/api/port-calls \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"vessel_id\": 1, \"eta\": \"2026-06-15 14:30:00\"}'"
echo ""
echo "📖 Para más información, consulta:"
echo "   - README.md (Resumen general)"
echo "   - TESTING_GUIDE.md (Ejemplos de prueba)"
echo "   - TECHNICAL_DOCS.md (Documentación técnica)"
echo ""
