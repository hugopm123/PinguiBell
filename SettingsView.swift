import SwiftUI

struct SettingsView: View {
    // MARK: - Persistence
    @AppStorage("SelectedAnimal") private var selectedAnimal = "penguin"
    @AppStorage("AppearanceDuration") private var appearanceDuration = 5.0
    @AppStorage("AnimationFrameRate") private var animationFrameRate = 0.1
    @AppStorage("AppearanceFrequency") private var appearanceFrequency = 0
    
    // MARK: - Constants
    private let animals = ["penguin", "cat", "fox", "capibara", "camaleon"]
    private let frequencies = ["Hora", "30 min", "15 min"]
    
    // MARK: - Computed Properties
    private var speedBinding: Binding<Double> {
        Binding(
            get: { (0.2 - animationFrameRate) / (0.2 - 0.02) },
            set: { 
                animationFrameRate = 0.2 - ($0 * (0.2 - 0.02))
                notifyUpdate()
            }
        )
    }
    
    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            mainContent
        }
        .frame(minWidth: 600, minHeight: 550)
    }
    
    // MARK: - View Components
    
    private var sidebar: some View {
        VStack(spacing: 25) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 42, height: 42)
                .padding(.top, 45)
            
            Spacer()
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                VStack(spacing: 4) {
                    Image(systemName: "power")
                        .font(.system(size: 18, weight: .bold))
                    Text("Salir")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.red)
                .frame(width: 50, height: 50)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 30)
        }
        .frame(width: 80)
        .frame(maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 30) {
                    animalSelectionSection
                    settingsSection
                }
                .padding(.horizontal, 30)
            }
            
            Spacer()
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var header: some View {
        Text("Configuración General")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .padding(.horizontal, 30)
            .padding(.top, 40)
            .padding(.bottom, 20)
    }
    
    private var animalSelectionSection: some View {
        SectionWrapper(title: "Mascota", icon: "pawprint.fill") {
            HStack(spacing: 12) {
                ForEach(animals, id: \.self) { animal in
                    AnimalSolidCard(animal: animal, isSelected: selectedAnimal == animal) {
                        selectedAnimal = animal
                        notifyUpdate()
                    }
                }
            }
        }
    }
    
    private var settingsSection: some View {
        SectionWrapper(title: "Frecuencia y Tiempo", icon: "slider.horizontal.3") {
            VStack(spacing: 18) {
                Picker("Frecuencia", selection: $appearanceFrequency) {
                    ForEach(0..<frequencies.count, id: \.self) { index in
                        Text(frequencies[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: appearanceFrequency) { notifyUpdate() }
                
                SettingsSlider(title: "Tiempo", value: $appearanceDuration, range: 3...60, unit: "s")
                    .onChange(of: appearanceDuration) { notifyUpdate() }
                
                SettingsSlider(title: "Velocidad", value: speedBinding, range: 0...1, label: speedLabel)
            }
            .padding(20)
            .background(Color.primary.opacity(0.03))
            .cornerRadius(15)
        }
    }
    
    private var footer: some View {
        HStack {
            Text("v1.2.0")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
            Spacer()
            Button(action: { NotificationCenter.default.post(name: Notification.Name("ShowPenguinManual"), object: nil) }) {
                Text("Probar Mascota")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(25)
    }
    
    // MARK: - Helpers
    
    private var speedLabel: String {
        if animationFrameRate <= 0.03 { return "Turbo" }
        if animationFrameRate <= 0.07 { return "Rápido" }
        if animationFrameRate <= 0.15 { return "Normal" }
        return "Lento"
    }
    
    private func notifyUpdate() {
        NotificationCenter.default.post(name: Notification.Name("UpdateMenu"), object: nil)
    }
}

// MARK: - Components

struct SectionWrapper<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            content
        }
    }
}

struct SettingsSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var unit: String = ""
    var label: String? = nil
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title).font(.system(size: 12, weight: .medium))
                Spacer()
                Text(label ?? "\(Int(value))\(unit)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Slider(value: $value, in: range)
        }
    }
}

struct AnimalSolidCard: View {
    let animal: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.05))
                        .frame(width: 75, height: 75)
                    
                    if let image = loadAnimalImage(animal) {
                        Image(nsImage: image)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 50, height: 50)
                    }
                }
                Text(animal.capitalized).font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
        }
        .buttonStyle(.plain)
    }
    
    private func loadAnimalImage(_ name: String) -> NSImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "png"),
              let originalImage = NSImage(contentsOfFile: path) else { return nil }
        let frameSize = originalImage.size.width / 4
        let rect = NSRect(x: 0, y: originalImage.size.height - frameSize, width: frameSize, height: frameSize)
        let croppedImage = NSImage(size: rect.size)
        croppedImage.lockFocus()
        originalImage.draw(in: NSRect(origin: .zero, size: rect.size), from: rect, operation: .copy, fraction: 1.0)
        croppedImage.unlockFocus()
        return croppedImage
    }
}
