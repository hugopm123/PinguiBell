# PinguiBell 🐧

**PinguiBell** es una aplicación nativa para macOS que trae una pequeña mascota animada a tu escritorio para acompañarte mientras trabajas. Puedes programar su aparición para que te recuerde tomar descansos o simplemente para alegrar tu día.

## ✨ Características

- **🐾 Variedad de Mascotas**: Elige entre un Pingüino, Gato, Zorro, Capibara o Camaleón.
- **🕒 Programación Inteligente**: Configura la frecuencia de aparición (cada 15 min, 30 min o cada hora en punto).
- **⚙️ Altamente Personalizable**:
  - Ajusta el **tiempo de permanencia** en pantalla (de 3 segundos a 1 minuto).
  - Controla la **velocidad de la animación** (desde Lento hasta Turbo).
- **🖥️ Integración Nativa**: Funciona discretamente desde la barra de menús de macOS.
- **🌈 Transparencia Total**: Las mascotas aparecen como overlays transparentes en la esquina inferior derecha de tu pantalla sin interrumpir tu flujo de trabajo.

## 🚀 Instalación y Uso

### Requisitos
- macOS 11.0 o superior.

### Construcción desde el código fuente
Si deseas compilar la aplicación tú mismo:

1. Clona el repositorio.
2. Abre la terminal en la carpeta del proyecto.
3. Ejecuta el script de construcción:
   ```bash
   ./build.sh
   ```
4. Para generar el instalador (.dmg):
   ```bash
   ./make_dmg.sh
   ```

La aplicación compilada aparecerá en la carpeta `build/`.

## 🛠️ Tecnologías

- **Swift**: Lenguaje principal.
- **SwiftUI & AppKit**: Para la interfaz de usuario y la gestión de ventanas transparentes de macOS.
- **Manejo de Sprites**: Sistema personalizado de animación de frames a partir de hojas de sprites (PNG).

## 📂 Estructura del Proyecto

- `PinguiBellApp.swift`: Punto de entrada y lógica de la barra de menús.
- `OverlayWindow.swift`: Configuración de la ventana transparente.
- `PenguinView.swift`: Motor de animación de los sprites.
- `TimeManager.swift`: Sistema de programación basado en el reloj del sistema.
- `*.png`: Hojas de sprites de las diferentes mascotas.
