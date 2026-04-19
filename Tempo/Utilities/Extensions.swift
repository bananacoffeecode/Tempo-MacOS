import Foundation

extension Int {
    /// Formats a total seconds count as HH:MM:SS.
    var asElapsedTime: String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = self % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

extension Date {
    /// Seconds elapsed between this date and now, formatted as HH:MM:SS.
    var elapsedFormatted: String {
        Int(Date.now.timeIntervalSince(self)).asElapsedTime
    }
}
