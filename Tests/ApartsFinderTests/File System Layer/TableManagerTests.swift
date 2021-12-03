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
    
    func test_sync_performance() throws {
        let content = "name,url,price,address"
        let fileNamesSync = [
            "table_1_sync.csv",
            "table_2_sync.csv",
            "table_3_sync.csv"
        ]
        
        measure {
            Task {
                try! await TableManager(filePath: fileBasePath + fileNamesSync[0]).writeAsync(content)
                try! await TableManager(filePath: fileBasePath + fileNamesSync[1]).writeAsync(content)
                try! await TableManager(filePath: fileBasePath + fileNamesSync[2]).writeAsync(content)
            }
        }
        
        try! fileManager.removeFile(atPath: fileBasePath + fileNamesSync[0])
        try! fileManager.removeFile(atPath: fileBasePath + fileNamesSync[1])
        try! fileManager.removeFile(atPath: fileBasePath + fileNamesSync[2])
    }
    
    func test_async_performance() throws {
        let content = "name,url,price,address"
        let fileNamesAsync = [
            "table_1_async.csv",
            "table_2_async.csv",
            "table_3_async.csv"
        ]

        measure {
            Task {
                let _ = await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
                    for fileName in fileNamesAsync {
                        let path = fileBasePath + fileName
                        
                        taskGroup.addTask {
                            try! await TableManager(filePath: path).writeAsync(content)
                        }
                    }
                })
            }
        }
        
        try! fileManager.removeFile(atPath: fileBasePath + fileNamesAsync[0])
        try! fileManager.removeFile(atPath: fileBasePath + fileNamesAsync[1])
        try! fileManager.removeFile(atPath: fileBasePath + fileNamesAsync[2])
    }
}
