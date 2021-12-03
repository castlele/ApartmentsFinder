import XCTest
import Core

final class LinkedListTests: XCTestCase {
    let data = [
        "afind", "table.csv", "[id,name,url]",
        "-p", "12000", "24000",
        "-l", "Moscow",
        "-r", "1", "2"
    ]
    
    func testInit() throws {
        let linkedList = LinkedList(data)
        
        let expectedRepresentation = "afind -> table.csv -> [id,name,url] -> -p -> 12000 -> 24000 -> -l -> Moscow -> -r -> 1 -> 2"
        
        XCTAssertEqual(linkedList.description, expectedRepresentation)
    }
}
