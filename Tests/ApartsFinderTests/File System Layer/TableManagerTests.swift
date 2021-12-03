import XCTest
import Core

final class TableManagerTests: XCTestCase {
    enum TableManagerError: Error {
        case cantReadFile(atPath: String)
    }
    
    let fileManager = FileSystemManager.shared
    let fileBasePath = "/Users/castlelecs/Documents/"
    let fileName = "/Users/castlelecs/Documents/test_table.csv"
    
    override func setUpWithError() throws {
        guard !fileManager.isExists(filePath: fileName) else {
            try fileManager.removeFile(atPath: fileName)
            return
        }
    }
    
    override func tearDownWithError() throws {
        if fileManager.isExists(filePath: fileName) {
            try fileManager.removeFile(atPath: fileName)
        }
    }
    
    func test_create_file() async throws {
        let tableManager = TableManager(filePath: fileName)
        let expectedContent = "name,url,price,address"
        
        await tableManager.createFileAsync()
        
        try! await tableManager.writeAsync(expectedContent)
        
        await tableManager.createFileAsync()
        
        let content = await tableManager.readAsync()
        
        XCTAssertEqual(content, expectedContent)
    }
    
    func test_read() async throws {
        let tableManager = TableManager(filePath: fileName)
        
        let nilReadResult = await tableManager.readAsync()
        XCTAssertNil(nilReadResult)
        
        XCTAssertTrue(fileManager.createFile(atPath: fileName))
        
        guard let emptyReadResult = await tableManager.readAsync() else {
            throw TableManagerError.cantReadFile(atPath: fileName)
        }
        
        XCTAssertTrue(emptyReadResult.isEmpty)
    }
    
    func test_write() async throws {
        let tableManager = TableManager(filePath: fileName)
        let expectedContent = "name,url,price,address"
        
        try await tableManager.writeAsync(expectedContent)
        XCTAssertTrue(fileManager.isExists(filePath: fileName))
        
        guard let content = await tableManager.readAsync() else {
            throw TableManagerError.cantReadFile(atPath: fileName)
        }
        
        XCTAssertEqual(content, expectedContent)
        
        let expectedReversedContent = "adddress,price,url,name"
        try await tableManager.writeAsync(expectedReversedContent)
        
        guard let reversedContent = await tableManager.readAsync() else {
            throw TableManagerError.cantReadFile(atPath: fileName)
        }
        
        XCTAssertEqual(reversedContent, expectedReversedContent)
    }
}
