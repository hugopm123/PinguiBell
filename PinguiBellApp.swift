import SwiftUI
import AppKit

@main
struct PinguiBellApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Usamos Settings para que no se cree una ventana vacía al inicio
        // La ventana principal la gestionará el AppDelegate
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var settingsWindow: NSWindow?
    private var overlayWindow: OverlayWindow?
    private var statusItem: NSStatusItem?
    private let animals = ["penguin", "cat", "fox", "capibara", "camaleon"]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupTimeManager()
        
        NSApp.activate(ignoringOtherApps: true)
        setupNotificationObservers()
        
        // Mostrar ventana y mascota al inicio
        openMainWindow()
        showPet()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    
    // MARK: - Setup
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: Notification.Name("UpdateMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPet), name: Notification.Name("ShowPenguinManual"), object: nil)
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        refreshUI()
    }
    
    @objc private func refreshUI() {
        updateStatusItemIcon()
        updateMenu()
    }
    
    // MARK: - Window Management (FIX: Reapertura de ventana)
    
    @objc private func openMainWindow() {
        if settingsWindow == nil {
            // Crear la ventana si no existe
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 550),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = "Configuración PinguiBell"
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.isReleasedWhenClosed = false // IMPORTANTE: No destruir la ventana al cerrar
            window.center()
            
            // Hosting del contenido SwiftUI
            window.contentView = NSHostingView(rootView: SettingsView())
            self.settingsWindow = window
        }
        
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func updateStatusItemIcon() {
        let animal = UserDefaults.standard.string(forKey: "SelectedAnimal") ?? "penguin"
        if let path = Bundle.main.path(forResource: animal, ofType: "png"),
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
        statusItem?.button?.image = NSImage(systemSymbolName: "pawprint.fill", accessibilityDescription: "PinguiBell")
    }
    
    private func updateMenu() {
        let menu = NSMenu()
        let defaults = UserDefaults.standard
        
        menu.addItem(withTitle: "Abrir Configuración ⚙️", action: #selector(openMainWindow), keyEquivalent: "s")
        menu.addItem(withTitle: "Probar Mascota 🐧", action: #selector(showPet), keyEquivalent: "p")
        menu.addItem(NSMenuItem.separator())
        
        // --- SECCIONES QUICK-ACCESS ---
        let animalMenu = NSMenu()
        let currentAnimal = defaults.string(forKey: "SelectedAnimal") ?? "penguin"
        for animal in animals {
            let item = NSMenuItem(title: animal.capitalized, action: #selector(selectAnimal(_:)), keyEquivalent: "")
            item.representedObject = animal
            if animal == currentAnimal { item.state = .on }
            animalMenu.addItem(item)
        }
        menu.addItem(withTitle: "Elegir Animal", submenu: animalMenu)
        
        let durationMenu = NSMenu()
        let currentDuration = defaults.double(forKey: "AppearanceDuration").zeroIs(5.0)
        for d in [3.0, 5.0, 10.0, 30.0, 60.0] {
            let item = NSMenuItem(title: d < 60 ? "\(Int(d)) segundos" : "1 minuto", action: #selector(setDuration(_:)), keyEquivalent: "")
            item.representedObject = d
            if d == currentDuration { item.state = .on }
            durationMenu.addItem(item)
        }
        menu.addItem(withTitle: "Tiempo en Pantalla", submenu: durationMenu)
        
        let speedMenu = NSMenu()
        let currentSpeed = defaults.double(forKey: "AnimationFrameRate").zeroIs(0.1)
        for (name, val) in [("Lento", 0.2), ("Normal", 0.1), ("Rápido", 0.05), ("Turbo", 0.02)] {
            let item = NSMenuItem(title: name, action: #selector(setSpeed(_:)), keyEquivalent: "")
            item.representedObject = val
            if val == currentSpeed { item.state = .on }
            speedMenu.addItem(item)
        }
        menu.addItem(withTitle: "Velocidad Animación", submenu: speedMenu)
        
        let freqMenu = NSMenu()
        let currentFreq = defaults.integer(forKey: "AppearanceFrequency")
        for (title, val) in [("Cada hora", 0), ("Cada 30 minutos", 1), ("Cada 15 minutos", 2)] {
            let item = NSMenuItem(title: title, action: #selector(setFrequency(_:)), keyEquivalent: "")
            item.representedObject = val
            if val == currentFreq { item.state = .on }
            freqMenu.addItem(item)
        }
        menu.addItem(withTitle: "Frecuencia", submenu: freqMenu)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Salir", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        statusItem?.menu = menu
    }
    
    // MARK: - Handlers
    
    @objc private func showPet() {
        guard let screen = NSScreen.main else { return }
        let duration = UserDefaults.standard.double(forKey: "AppearanceDuration").zeroIs(5.0)
        let rect = calculatePetRect(in: screen.visibleFrame)
        
        if overlayWindow == nil { overlayWindow = OverlayWindow(contentRect: rect) }
        overlayWindow?.contentView = NSHostingView(rootView: PenguinView())
        overlayWindow?.makeKeyAndOrderFront(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 1.0) { [weak self] in
            self?.overlayWindow?.orderOut(nil)
        }
    }
    
    @objc private func selectAnimal(_ sender: NSMenuItem) {
        if let animal = sender.representedObject as? String {
            UserDefaults.standard.set(animal, forKey: "SelectedAnimal")
            refreshUI()
        }
    }
    
    @objc private func setDuration(_ sender: NSMenuItem) {
        if let d = sender.representedObject as? Double {
            UserDefaults.standard.set(d, forKey: "AppearanceDuration")
            refreshUI()
        }
    }
    
    @objc private func setSpeed(_ sender: NSMenuItem) {
        if let s = sender.representedObject as? Double {
            UserDefaults.standard.set(s, forKey: "AnimationFrameRate")
            refreshUI()
        }
    }
    
    @objc private func setFrequency(_ sender: NSMenuItem) {
        if let f = sender.representedObject as? Int {
            UserDefaults.standard.set(f, forKey: "AppearanceFrequency")
            refreshUI()
            TimeManager.shared.scheduleNextEvent()
        }
    }
    
    private func calculatePetRect(in screenFrame: NSRect) -> NSRect {
        let size: CGFloat = 200
        return NSRect(x: screenFrame.maxX - size - 20, y: screenFrame.minY + 20, width: size, height: size)
    }
    
    private func setupTimeManager() {
        TimeManager.shared.onTick = { [weak self] in
            DispatchQueue.main.async { self?.showPet() }
        }
    }
}

// MARK: - Helpers
extension NSMenu {
    func addItem(withTitle title: String, submenu: NSMenu) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.submenu = submenu
        self.addItem(item)
    }
}

extension Double {
    func zeroIs(_ value: Double) -> Double { self == 0 ? value : self }
}
