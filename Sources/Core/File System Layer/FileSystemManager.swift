import Foundation

public struct FileSystemManager {
    public static let shared = FileSystemManager()
    
    private let fileManager = FileManager.default
    
    private init() { }
    
    public func isExists(filePath file: String) -> Bool {
        fileManager.fileExists(atPath: file)
    }
    
    @discardableResult
    public func createFile(atPath file: String) -> Bool {
        fileManager.createFile(atPath: file, contents: nil, attributes: nil)
    }
    
    public func removeFile(atPath file: String) throws {
        try fileManager.removeItem(atPath: file)
    }
}
