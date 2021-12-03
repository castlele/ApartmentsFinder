import XCTest
import Core

final class CommandTests: XCTestCase {
    enum TestKey: String, CLKey {
        case fileName = "1"
        case price
        case location = "-l"
    }
    
    override func setUp() {
        Command.setSessionCommands(TestKey.allCases.map { $0.rawValue })
    }
    
    override func tearDown() {
        Command.setSessionCommands([])
    }
    
    func testIsValid() throws {
        let validIndexCmd = Command(1)
        let invalidIndexCmd = Command(0)
        let validName_1 = Command("price")
        let validName_2 = Command("-l")
        let invalidName_1 = Command("")
        let invalidName_2 = Command("location")
        let invalidName_3 = Command("Location")
        
        XCTAssertEqual(validIndexCmd?.cmd, "1")
        XCTAssertEqual(invalidIndexCmd?.cmd, nil)
        XCTAssertEqual(validName_1?.cmd, "price")
        XCTAssertEqual(validName_2?.cmd, "-l")
        XCTAssertEqual(invalidName_1?.cmd, nil)
        XCTAssertEqual(invalidName_2?.cmd, nil)
        XCTAssertEqual(invalidName_3?.cmd, nil)
    }
}
