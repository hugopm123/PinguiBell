import SwiftUI
import AppKit

@main
struct PinguiBellApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SettingsView()
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        window.title = "Configuración PinguiBell"
                        window.styleMask.insert(.resizable)
                        // Asegurar que la ventana sea sólida
                        window.isOpaque = true
                        window.hasShadow = true
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: OverlayWindow?
    var statusItem: NSStatusItem?
    
    let animals = ["penguin", "cat", "fox", "capibara", "camaleon"]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupTimeManager()
        
        // Asegurar que la ventana sea visible al inicio (importante cuando LSUIElement es true)
        NSApp.activate(ignoringOtherApps: true)
        
        // Observadores para sincronizar con la ventana de configuración
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateMenu), name: Notification.Name("UpdateMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPenguinManual), name: Notification.Name("ShowPenguinManual"), object: nil)
        
        // Mostrar el pingüino al inicio
        showPenguin()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    @objc func handleUpdateMenu() {
        updateMenu()
        updateStatusItemIcon()
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusItemIcon()
        updateMenu()
    }
    
    func updateStatusItemIcon() {
        let currentAnimal = UserDefaults.standard.string(forKey: "SelectedAnimal") ?? "penguin"
        
        if let path = Bundle.main.path(forResource: currentAnimal, ofType: "png"),
           let originalImage = NSImage(contentsOfFile: path) {
            
            let frameSize = originalImage.size.width / 4
            if frameSize > 0 {
                let rect = NSRect(x: 0, y: originalImage.size.height - frameSize, width: frameSize, height: frameSize)
                let iconImage = NSImage(size: NSSize(width: 18, height: 18))
                iconImage.lockFocus()
                originalImage.draw(in: NSRect(x: 0, y: 0, width: 18, height: 18), from: rect, operation: .copy, fraction: 1.0)
                iconImage.unlockFocus()
                iconImage.isTemplate = true
                statusItem?.button?.image = iconImage
                return
            }
        }
        
        // Fallback
        statusItem?.button?.image = NSImage(systemSymbolName: "pawprint.fill", accessibilityDescription: "PinguiBell")
    }
    
    func updateMenu() {
        let menu = NSMenu()
        let currentAnimal = UserDefaults.standard.string(forKey: "SelectedAnimal") ?? "penguin"
        let currentDuration = UserDefaults.standard.double(forKey: "AppearanceDuration") == 0 ? 5.0 : UserDefaults.standard.double(forKey: "AppearanceDuration")
        let currentSpeed = UserDefaults.standard.double(forKey: "AnimationFrameRate") == 0 ? 0.1 : UserDefaults.standard.double(forKey: "AnimationFrameRate")
        
        menu.addItem(NSMenuItem(title: "Abrir Configuración ⚙️", action: #selector(openMainWindow), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Probar Mascota 🐧", action: #selector(showPenguinManual), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        
        // --- SECCIÓN: ELEGIR ANIMAL ---
        let animalMenu = NSMenu()
        for animal in animals {
            let item = NSMenuItem(title: animal.capitalized, action: #selector(selectAnimal(_:)), keyEquivalent: "")
            item.representedObject = animal
            if animal == currentAnimal { item.state = .on }
            animalMenu.addItem(item)
        }
        let selectItem = NSMenuItem(title: "Elegir Animal", action: nil, keyEquivalent: "")
        selectItem.submenu = animalMenu
        menu.addItem(selectItem)
        
        // --- SECCIÓN: DURACIÓN ---
        let durationMenu = NSMenu()
        let durations: [Double] = [3, 5, 10, 30, 60]
        for d in durations {
            let title = d < 60 ? "\(Int(d)) segundos" : "1 minuto"
            let item = NSMenuItem(title: title, action: #selector(setDuration(_:)), keyEquivalent: "")
            item.representedObject = d
            if d == currentDuration { item.state = .on }
            durationMenu.addItem(item)
        }
        let durationItem = NSMenuItem(title: "Tiempo en Pantalla", action: nil, keyEquivalent: "")
        durationItem.submenu = durationMenu
        menu.addItem(durationItem)
        
        // --- SECCIÓN: VELOCIDAD ---
        let speedMenu = NSMenu()
        let speeds: [(String, Double)] = [("Lento", 0.2), ("Normal", 0.1), ("Rápido", 0.05), ("Turbo", 0.02)]
        for (name, val) in speeds {
            let item = NSMenuItem(title: name, action: #selector(setSpeed(_:)), keyEquivalent: "")
            item.representedObject = val
            if val == currentSpeed { item.state = .on }
            speedMenu.addItem(item)
        }
        let speedItem = NSMenuItem(title: "Velocidad Animación", action: nil, keyEquivalent: "")
        speedItem.submenu = speedMenu
        menu.addItem(speedItem)
        
        // --- SECCIÓN: FRECUENCIA ---
        let freqMenu = NSMenu()
        let currentFreq = UserDefaults.standard.integer(forKey: "AppearanceFrequency") // 0: Hora, 1: 30m, 2: 15m
        
        let hourlyItem = NSMenuItem(title: "Cada hora (:00)", action: #selector(setFrequency(_:)), keyEquivalent: "")
        hourlyItem.representedObject = 0
        if currentFreq == 0 { hourlyItem.state = .on }
        freqMenu.addItem(hourlyItem)
        
        let halfHourlyItem = NSMenuItem(title: "Cada 30 minutos (:00, :30)", action: #selector(setFrequency(_:)), keyEquivalent: "")
        halfHourlyItem.representedObject = 1
        if currentFreq == 1 { halfHourlyItem.state = .on }
        freqMenu.addItem(halfHourlyItem)
        
        let quarterHourlyItem = NSMenuItem(title: "Cada 15 minutos (:00, :15, :30, :45)", action: #selector(setFrequency(_:)), keyEquivalent: "")
        quarterHourlyItem.representedObject = 2
        if currentFreq == 2 { quarterHourlyItem.state = .on }
        freqMenu.addItem(quarterHourlyItem)
        
        let freqItem = NSMenuItem(title: "Frecuencia", action: nil, keyEquivalent: "")
        freqItem.submenu = freqMenu
        menu.addItem(freqItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Salir", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "Configuración PinguiBell" }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // Si por alguna razón no existe, intentamos buscar cualquier ventana que no sea la del penguin
            NSApp.windows.forEach { window in
                if !(window is OverlayWindow) {
                    window.makeKeyAndOrderFront(nil)
                }
            }
        }
    }
    
    @objc func setFrequency(_ sender: NSMenuItem) {
        if let f = sender.representedObject as? Int {
            UserDefaults.standard.set(f, forKey: "AppearanceFrequency")
            updateMenu()
            // Notificar al TimeManager para que recalcule de inmediato
            TimeManager.shared.scheduleNextEvent()
        }
    }
    
    @objc func setDuration(_ sender: NSMenuItem) {
        if let d = sender.representedObject as? Double {
            UserDefaults.standard.set(d, forKey: "AppearanceDuration")
            updateMenu()
        }
    }
    
    @objc func setSpeed(_ sender: NSMenuItem) {
        if let s = sender.representedObject as? Double {
            UserDefaults.standard.set(s, forKey: "AnimationFrameRate")
            updateMenu()
        }
    }
    
    @objc func selectAnimal(_ sender: NSMenuItem) {
        if let animal = sender.representedObject as? String {
            UserDefaults.standard.set(animal, forKey: "SelectedAnimal")
            updateMenu()
            updateStatusItemIcon()
        }
    }
    
    @objc func showPenguinManual() {
        showPenguin()
    }
    
    func setupTimeManager() {
        TimeManager.shared.onHourPassed = { [weak self] in
            DispatchQueue.main.async {
                self?.showPenguin()
            }
        }
    }
    
    func showPenguin() {
        // Obtener la pantalla principal y su frame
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        
        // Obtener configuración de duración
        let duration = UserDefaults.standard.double(forKey: "AppearanceDuration") == 0 ? 5.0 : UserDefaults.standard.double(forKey: "AppearanceDuration")
        
        // Posición: Esquina inferior derecha
        let width: CGFloat = 200
        let height: CGFloat = 200
        let rect = NSRect(
            x: screenFrame.maxX - width - 20,
            y: screenFrame.minY + 20,
            width: width,
            height: height
        )
        
        // Crear o reutilizar ventana
        if overlayWindow == nil {
            overlayWindow = OverlayWindow(contentRect: rect)
        }
        
        // Configurar la vista de SwiftUI
        let contentView = PenguinView()
        overlayWindow?.contentView = NSHostingView(rootView: contentView)
        
        // Mostrar ventana
        overlayWindow?.makeKeyAndOrderFront(nil)
        
        // Cerrar ventana después de la duración seleccionada (+1s de margen)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 1.0) { [weak self] in
            self?.overlayWindow?.orderOut(nil)
        }
    }
}
