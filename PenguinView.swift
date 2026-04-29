import SwiftUI

struct PenguinView: View {
    @State private var isVisible = false
    @State private var currentFrame = 0
    
    // Configuración del sprite (4x4)
    private let columns = 4
    private let rows = 4
    private let totalFrames = 16
    
    var body: some View {
        let frameRate = UserDefaults.standard.double(forKey: "AnimationFrameRate") == 0 ? 0.1 : UserDefaults.standard.double(forKey: "AnimationFrameRate")
        let duration = UserDefaults.standard.double(forKey: "AppearanceDuration") == 0 ? 5.0 : UserDefaults.standard.double(forKey: "AppearanceDuration")
        
        VStack {
            if isVisible, let image = currentSpriteFrame() {
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .onReceive(Timer.publish(every: frameRate, on: .main, in: .common).autoconnect()) { _ in
            if isVisible {
                currentFrame = (currentFrame + 1) % totalFrames
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation {
                    isVisible = false
                }
            }
        }
    }
    
    // Función para recortar el frame actual de la imagen original
    func currentSpriteFrame() -> NSImage? {
        let currentAnimal = UserDefaults.standard.string(forKey: "SelectedAnimal") ?? "penguin"
        
        guard let path = Bundle.main.path(forResource: currentAnimal, ofType: "png"),
              let originalImage = NSImage(contentsOfFile: path) else {
            return nil
        }
        
        let frameWidth = originalImage.size.width / CGFloat(columns)
        let frameHeight = originalImage.size.height / CGFloat(rows)
        
        let col = currentFrame % columns
        let row = (totalFrames - 1 - currentFrame) / columns
        
        let rect = NSRect(
            x: CGFloat(col) * frameWidth,
            y: CGFloat(row) * frameHeight,
            width: frameWidth,
            height: frameHeight
        )
        
        let croppedImage = NSImage(size: rect.size)
        croppedImage.lockFocus()
        originalImage.draw(in: NSRect(origin: .zero, size: rect.size), from: rect, operation: .copy, fraction: 1.0)
        croppedImage.unlockFocus()
        
        return croppedImage
    }
}

#Preview {
    PenguinView()
        .background(Color.black.opacity(0.1))
}
