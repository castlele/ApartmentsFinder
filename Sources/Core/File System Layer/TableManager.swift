/// Responsible for making operations under table file
public struct TableManager {
    private let fileManager = FileSystemManager.shared
    private let filePath: String
    
    public init(filePath: String) {
        self.filePath = filePath
    }
    
    public static func convertFromCSV(_ csvRow: String) -> Apartment {
        let objects = csvRow.components(separatedBy: " , ")
        var apartment = Apartment()
        
        for (index, object) in objects.enumerated() {
            var strObject: String? = String(object)
            
            strObject?.removeLast()
            strObject?.removeFirst()
            
            if strObject == "None" {
                strObject = nil
            }
            
            switch Apartment.tableColumns[index] {
                case .name:
                    apartment.name = strObject
                case .url:
                    apartment.url = strObject
                case .price:
                    apartment.price = strObject
                case .additionalInfo:
                    apartment.additionalInfo = strObject
                case .address:
                    apartment.address = strObject
            }
        }
        return apartment
    }
    
    public func createFileAsync() async {
        if !isFileExists() {
            fileManager.createFile(atPath: filePath)
        }
    }
    
    public func createFile() {
        if !isFileExists() {
            fileManager.createFile(atPath: filePath)
        }
    }
    
    public func readAsync() async -> String? {
        guard isFileExists() else {
            return nil
        }
        
        do {
            return try String(contentsOfFile: filePath)
        } catch {
            return nil
        }
    }
    
    public func read() -> String? {
        guard isFileExists() else {
            return nil
        }
        
        do {
            return try String(contentsOfFile: filePath)
        } catch {
            return nil
        }
    }
    
    public func writeAsync(_ content: String) async throws {
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    public func write(_ content: String) throws {
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    private func isFileExists() -> Bool {
        fileManager.isExists(filePath: filePath)
    }
}
