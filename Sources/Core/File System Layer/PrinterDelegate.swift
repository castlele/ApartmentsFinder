public protocol PrinterDelegateProtocol {
    var logger: Logger? { get }
    
    func fileWasCreated(fileName: String)
    func apartmentsWereConvertedToCSV(csv: String)
    func tableWasFilled(table: Table<Apartment>)
    func readContentFromFile(content: [Apartment])
    func changesWereSavedToFile(content: String)
}

extension PrinterDelegateProtocol {
    nonisolated public func fileWasCreated(fileName: String) {
        logger?.out("File \(fileName) was created.")
    }

    nonisolated public func apartmentsWereConvertedToCSV(csv: String) {
        logger?.out("Apartments were converted to csv format:\n\(csv)")
    }

    nonisolated public func tableWasFilled(table: Table<Apartment>) {
        logger?.out("Table was filled with apartments:\n\(table)")
    }

    nonisolated public func readContentFromFile(content: [Apartment]) {
        logger?.out("Content from the file was read:\n\(content)")
    }

    nonisolated public func changesWereSavedToFile(content: String) {
        logger?.out("Changes were saved to the file. Current state of the file:\n\(content)")
    }
}

public struct PrinterDelegate: PrinterDelegateProtocol {
    public var logger: Logger?
    
    public init(logger: Logger?) {
        self.logger = logger
    }
}
