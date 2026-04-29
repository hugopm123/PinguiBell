#!/bin/bash

# Configuración
APP_NAME="PinguiBell"
BUILD_DIR="build"
CONTENTS_DIR="$BUILD_DIR/$APP_NAME.app/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🚀 Iniciando compilación de $APP_NAME Nativo..."

# Limpiar build anterior
rm -rf "$BUILD_DIR"

# Crear estructura del bundle
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compilar
swiftc -o "$MACOS_DIR/$APP_NAME" \
    PinguiBellApp.swift \
    OverlayWindow.swift \
    PenguinView.swift \
    TimeManager.swift \
    -framework SwiftUI \
    -framework AppKit \
    -sdk $(xcrun --show-sdk-path --sdk macosx)

# Copiar Info.plist y Recursos
cp Info.plist "$CONTENTS_DIR/"
cp penguin.png "$RESOURCES_DIR/"
cp cat.png "$RESOURCES_DIR/"
cp fox.png "$RESOURCES_DIR/"
cp capibara.png "$RESOURCES_DIR/"
cp camaleon.png "$RESOURCES_DIR/"
cp PinguiBell.icns "$RESOURCES_DIR/"

echo "✅ Compilación completada: $BUILD_DIR/$APP_NAME.app"
echo "👉 Puedes ejecutarlo con: open $BUILD_DIR/$APP_NAME.app"
