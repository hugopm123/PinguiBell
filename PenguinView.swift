import SwiftUI

struct PenguinView: View {
    @State private var isVisible = false
    @State private var currentFrame = 0
    
    // MARK: - Constants
    private let columns = 4
    private let rows = 4
    private let totalFrames = 16
    
    // MARK: - Config
    private var frameRate: Double {
        UserDefaults.standard.double(forKey: "AnimationFrameRate").zeroIs(0.1)
    }
    
    private var duration: Double {
        UserDefaults.standard.double(forKey: "AppearanceDuration").zeroIs(5.0)
    }
    
    var body: some View {
        ZStack {
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
                withAnimation { isVisible = false }
            }
        }
    }
    
    // MARK: - Sprite Logic
    
    private func currentSpriteFrame() -> NSImage? {
        let animal = UserDefaults.standard.string(forKey: "SelectedAnimal") ?? "penguin"
        
        guard let path = Bundle.main.path(forResource: animal, ofType: "png"),
              let originalImage = NSImage(contentsOfFile: path) else {
            return nil
        }
        
        let frameWidth = originalImage.size.width / CGFloat(columns)
        let frameHeight = originalImage.size.height / CGFloat(rows)
        
        // El sprite se recorre de izquierda a derecha, de arriba a abajo.
        // En macOS/AppKit, (0,0) es la esquina inferior izquierda.
        let col = currentFrame % columns
        let row = (rows - 1) - (currentFrame / columns)
        
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
