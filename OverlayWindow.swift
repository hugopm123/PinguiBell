import AppKit
import SwiftUI

class OverlayWindow: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Propiedades críticas para el overlay
        self.isFloatingPanel = true
        self.level = .mainMenu + 1 // Por encima de casi todo
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        
        // Ignorar eventos de ratón para que sea "click-through"
        self.ignoresMouseEvents = true
        
        // Centrar en la pantalla o posicionar (se ajustará después)
        self.isMovableByWindowBackground = false
    }
}
