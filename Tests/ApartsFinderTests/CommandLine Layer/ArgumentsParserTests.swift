import XCTest
import Core

final class ArgumentsParserTests: XCTestCase {
    let parser = ArgumentsParser()
    
    override func setUp() {
        parser.delegate = parser
        Command.setSessionCommands(SessionArguments.sessionCommands)
    }
    
    override func tearDown() {
        Command.setSessionCommands([])
    }
    
    func testParsing() throws {
        let validArgs_1 = [
            // By default this will not cause an error.
            // But if file doesn't exist and there are no .csv file,
            // the error will occure later in the process of file management
            "afind", "table.csv", "[]",
            "-p", "24000", // It is valid to use only upper bounds
            "-l", "Moscow",
            "-r", "2"
        ]
        let validArgExpectation_1 = SessionArguments(
            fileName: "table.csv", columns: [],
            price: 0...24000, location: "Moscow", rooms: [2])
        
        let validArgs_2 = [
            "afind", "table.csv", "[id,name,url]",
            "-p", "12000", "24000",
            "-l", "Moscow",
            "-r", "1", "2"
        ]
        let validArgs_3 = [
            "afind", "table.csv ", "[id, name, url]", // All spaces will be trimmed
            "-p", "12000", "24000",
            "-l", "Moscow",
            "-r", "1", "2"
        ]
        let validArgExpectation_2_3 = SessionArguments(
            fileName: "table.csv", columns: ["id", "name", "url"],
            price: 12000...24000, location: "Moscow", rooms: [1, 2])
        
        let validArgs_4 = [
            // default is a keyword.
            // It will be searching for file with name tabel.csv or for any .csv file if table.csv doesn't exist.
            "afind", "default", "[]",
            "-p", "12000", "24000",
            "-l", "Moscow",
            "-r", "1", "2"
        ]
        let validArgs_5 = [
            "afind", "default", "[]",
            "-p", "24000", "12000", "12000", // Upper and lower bounds can be mixed and equal values can be repeated
            "-l", "Moscow",
            "-r", "1", "2", "2" // Equal values can be repeated
        ]
        let validArgExpectation_4_5 = SessionArguments(
            fileName: "default", columns: [],
            price: 12000...24000, location: "Moscow", rooms: [1, 2])
        
        let validArgs_6 = ["afind", "-help"]
        let validArgExpectation_6 = SessionArguments.help
        
        let invalidArgs_1 = [
            "afind", "default", "[id,name,url]",
            "-pasdf", "12000", "24000", // Invalid command label
            "-l", "Moscow",
            "-r", "1", "2"
        ]
        let invalidArgs_2 = [
            "afind",  // Second (file name) and third (columns' names) args are necessary
            "-p", "12000", "24000",
            "-l", "Moscow",
            "-r", "1", "2"
        ]
        let invalidArgs_3 = ["afind"]
        
        let invalidArgs_4 = [
            "afind", "table.csv", "[]",
            "-p", "hello", // Wrong type of command's value
            "-l", "Moscow",
            "-r", "1", "2"
        ]
        
        XCTAssertEqual(try parser.parse(validArgs_1), validArgExpectation_1)
        XCTAssertEqual(try parser.parse(validArgs_2), validArgExpectation_2_3)
        XCTAssertEqual(try parser.parse(validArgs_3), validArgExpectation_2_3)
        XCTAssertEqual(try parser.parse(validArgs_4), validArgExpectation_4_5)
        XCTAssertEqual(try parser.parse(validArgs_5), validArgExpectation_4_5)
        XCTAssertEqual(try parser.parse(validArgs_6), validArgExpectation_6)
        
        XCTAssertThrowsError(try parser.parse(invalidArgs_1))
        XCTAssertThrowsError(try parser.parse(invalidArgs_2))
        XCTAssertThrowsError(try parser.parse(invalidArgs_3))
        XCTAssertThrowsError(try parser.parse(invalidArgs_4))
    }
}
