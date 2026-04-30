import Foundation

class TimeManager: ObservableObject {
    static let shared = TimeManager()
    
    private var timer: Timer?
    var onTick: (() -> Void)?
    
    private init() {
        scheduleNextEvent()
    }
    
    func scheduleNextEvent() {
        timer?.invalidate()
        
        let now = Date()
        let calendar = Calendar.current
        let frequency = UserDefaults.standard.integer(forKey: "AppearanceFrequency") // 0: Hora, 1: 30m, 2: 15m
        
        var nextDate: Date?
        
        switch frequency {
        case 2: // Cada 15 minutos
            let intervals = [0, 15, 30, 45]
            let possibleDates = intervals.compactMap { 
                calendar.nextDate(after: now, matching: DateComponents(minute: $0, second: 0), matchingPolicy: .nextTime) 
            }
            nextDate = possibleDates.min()
            
        case 1: // Cada 30 minutos
            let next00 = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime)
            let next30 = calendar.nextDate(after: now, matching: DateComponents(minute: 30, second: 0), matchingPolicy: .nextTime)
            if let d00 = next00, let d30 = next30 {
                nextDate = min(d00, d30)
            } else {
                nextDate = next00 ?? next30
            }
            
        default: // Cada hora
            nextDate = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime)
        }
        
        guard let targetDate = nextDate else {
            // Reintentar en 1 minuto si falla el cálculo
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) { self.scheduleNextEvent() }
            return
        }
        
        let interval = targetDate.timeIntervalSince(now)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.onTick?()
            self?.scheduleNextEvent()
        }
    }
}
