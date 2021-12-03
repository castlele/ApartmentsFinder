import Foundation

/// Object for managing input of results into log file or terminal
public protocol Logger {
    func out(_ data: Any)
}

extension Logger {
    fileprivate func getTimeStamp() -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = "dd-MM-YYYY"
        return dateFormatter.string(from: .now)
    }
}

public struct StandardCLLogger: Logger {
    public func out(_ data: Any) {
        print("[\(getTimeStamp())]: \(data)")
    }
}
