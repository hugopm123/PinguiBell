#!/bin/bash

# Configuración
APP_NAME="PinguiBell"
DMG_NAME="PinguiBell.dmg"
BUILD_DIR="build"
STAGING_DIR="dmg_staging"

# --- CONFIGURACIÓN DE FIRMA ---
# Usamos tu nueva identidad "HugoDev"
DEVELOPER_ID="HugoDev" 
# ------------------------------

echo "📦 Iniciando proceso de empaquetado y firma profesional..."

# 1. Limpiar versiones previas
rm -f "$DMG_NAME"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# 2. Verificar que la app existe
if [ ! -d "$BUILD_DIR/$APP_NAME.app" ]; then
    echo "❌ Error: No se encontró la app en $BUILD_DIR. Ejecuta ./build.sh primero."
    exit 1
fi

# 3. FIRMAR LA APLICACIÓN
echo "🔐 Firmando la aplicación con '$DEVELOPER_ID'..."
# Usamos --deep para firmar todo el contenido y --options runtime para cumplir con los requisitos modernos de Apple
codesign --deep --force --options runtime --sign "$DEVELOPER_ID" "$BUILD_DIR/$APP_NAME.app"

# 4. Copiar la App al área de staging
cp -R "$BUILD_DIR/$APP_NAME.app" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# 5. CREAR EL DMG
echo "💿 Creando imagen de disco..."
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

# 6. FIRMAR EL DMG
echo "🔐 Firmando el instalador DMG..."
codesign --force --sign "$DEVELOPER_ID" "$DMG_NAME"

# 7. VERIFICACIÓN FINAL
echo "🔍 Verificando firma..."
codesign --verify --verbose "$DMG_NAME"

# Limpiar
rm -rf "$STAGING_DIR"

echo "✅ ¡HECHO! Tu instalador firmado está en: $DMG_NAME"
echo "🚀 Ahora puedes compartirlo. (Nota: Al ser firma personal, tus amigos aún verán un aviso, pero el archivo está autenticado)."
