import SwiftUI

struct SettingsView: View {
    @AppStorage("SelectedAnimal") private var selectedAnimal = "penguin"
    @AppStorage("AppearanceDuration") private var appearanceDuration = 5.0
    @AppStorage("AnimationFrameRate") private var animationFrameRate = 0.1
    @AppStorage("AppearanceFrequency") private var appearanceFrequency = 0
    
    let animals = ["penguin", "cat", "fox", "capibara", "camaleon"]
    
    // Propiedad calculada para manejar la velocidad de forma intuitiva (Inversa del frame rate)
    // Mapeamos 0.2 (Lento) -> 0.0 y 0.02 (Rápido) -> 1.0
    private var speedValue: Binding<Double> {
        Binding(
            get: {
                // Invertimos y normalizamos el valor para el slider (0.02 a 0.2)
                // Usamos una fórmula simple: (MaxDelay - CurrentDelay) / (MaxDelay - MinDelay)
                return (0.2 - animationFrameRate) / (0.2 - 0.02)
            },
            set: { newValue in
                // Convertimos el valor del slider (0 a 1) de vuelta a retraso (0.2 a 0.02)
                animationFrameRate = 0.2 - (newValue * (0.2 - 0.02))
                NotificationCenter.default.post(name: Notification.Name("UpdateMenu"), object: nil)
            }
        )
    }
    
    var body: some View {
        HStack(spacing: 0) {
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
            
            Divider()
            
            // MARK: - PANEL DE CONTROL
            VStack(alignment: .leading, spacing: 0) {
                Text("Configuración General")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .padding(.horizontal, 30)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Sección: Mascota
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Mascota", systemImage: "pawprint.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(animals, id: \.self) { animal in
                                    AnimalSolidCard(animal: animal, isSelected: selectedAnimal == animal) {
                                        selectedAnimal = animal
                                        NotificationCenter.default.post(name: Notification.Name("UpdateMenu"), object: nil)
                                    }
                                }
                            }
                        }
                        
                        // Sección: Ajustes
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Frecuencia y Tiempo", systemImage: "slider.horizontal.3")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 18) {
                                Picker("Frecuencia", selection: $appearanceFrequency) {
                                    Text("Hora").tag(0)
                                    Text("30 min").tag(1)
                                    Text("15 min").tag(2)
                                }
                                .pickerStyle(.segmented)
                                
                                SolidSliderRow(title: "Tiempo", value: $appearanceDuration, range: 3...60, unit: "s")
                                
                                // Slider de Velocidad con lógica corregida (Visualmente normal, lógicamente invertido)
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Velocidad").font(.system(size: 12, weight: .medium))
                                        Spacer()
                                        Text(speedLabel(animationFrameRate)).font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(.secondary)
                                    }
                                    Slider(value: speedValue, in: 0...1) // Ahora va de 0 a 1 de forma natural
                                }
                            }
                            .padding(20)
                            .background(Color.primary.opacity(0.03))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Footer
                HStack {
                    Text("v1.2")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        NotificationCenter.default.post(name: Notification.Name("ShowPenguinManual"), object: nil)
                    }) {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(minWidth: 550, minHeight: 500)
    }
    
    func speedLabel(_ val: Double) -> String {
        if val <= 0.03 { return "Turbo" }
        if val <= 0.07 { return "Rápido" }
        if val <= 0.15 { return "Normal" }
        return "Lento"
    }
}

struct SolidSliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var unit: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title).font(.system(size: 12, weight: .medium))
                Spacer()
                Text("\(Int(value))\(unit)").font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(.secondary)
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
    
    func loadAnimalImage(_ name: String) -> NSImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "png"),
              let originalImage = NSImage(contentsOfFile: path) else { return nil }
        let frameWidth = originalImage.size.width / 4
        let frameHeight = originalImage.size.height / 4
        let rect = NSRect(x: 0, y: originalImage.size.height - frameHeight, width: frameWidth, height: frameHeight)
        let croppedImage = NSImage(size: rect.size)
        croppedImage.lockFocus()
        originalImage.draw(in: NSRect(origin: .zero, size: rect.size), from: rect, operation: .copy, fraction: 1.0)
        croppedImage.unlockFocus()
        return croppedImage
    }
}
