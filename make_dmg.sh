#!/bin/bash

APP_NAME="PinguiBell"
DMG_NAME="PinguiBell.dmg"
BUILD_DIR="build"
STAGING_DIR="dmg_staging"

echo "📦 Creando instalador DMG..."

# 1. Limpiar versiones previas
rm -f "$DMG_NAME"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# 2. Copiar la App compilada
if [ ! -d "$BUILD_DIR/$APP_NAME.app" ]; then
    echo "❌ Error: No se encontró la app en $BUILD_DIR. Ejecuta ./build.sh primero."
    exit 1
fi

cp -R "$BUILD_DIR/$APP_NAME.app" "$STAGING_DIR/"

# 3. Crear el enlace simbólico a Aplicaciones
ln -s /Applications "$STAGING_DIR/Applications"

# 4. Crear el DMG usando hdiutil
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

# 5. Limpiar
rm -rf "$STAGING_DIR"

echo "✅ ¡Listo! Tu instalador está en: $DMG_NAME"
