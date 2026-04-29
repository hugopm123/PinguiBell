import Foundation

class TimeManager: ObservableObject {
    static let shared = TimeManager()
    
    private var timer: Timer?
    var onHourPassed: (() -> Void)?
    
    init() {
        scheduleNextEvent()
    }
    
    func scheduleNextEvent() {
        timer?.invalidate()
        
        let now = Date()
        let calendar = Calendar.current
        let frequency = UserDefaults.standard.integer(forKey: "AppearanceFrequency") // 0: Hora, 1: 30m, 2: 15m
        
        var nextDate: Date?
        
        if frequency == 2 {
            let intervals = [0, 15, 30, 45]
            var possibleDates: [Date] = []
            for m in intervals {
                if let d = calendar.nextDate(after: now, matching: DateComponents(minute: m, second: 0), matchingPolicy: .nextTime) {
                    possibleDates.append(d)
                }
            }
            nextDate = possibleDates.min()
        } else if frequency == 1 {
            let next00 = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime)
            let next30 = calendar.nextDate(after: now, matching: DateComponents(minute: 30, second: 0), matchingPolicy: .nextTime)
            
            if let d00 = next00, let d30 = next30 {
                nextDate = min(d00, d30)
            } else {
                nextDate = next00 ?? next30
            }
        } else {
            nextDate = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime)
        }
        
        guard let targetDate = nextDate else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) { self.scheduleNextEvent() }
            return
        }
        
        let interval = targetDate.timeIntervalSince(now)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.onHourPassed?()
            self?.scheduleNextEvent()
        }
    }
}
