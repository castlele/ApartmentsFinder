import XCTest
import Core

final class PrinterTests: XCTestCase {
    let path = "/Users/castlelecs/Documents/test.csv"
    let content = "name , url , price , additional_info , address\n\"1-к. квартира, 31,7 м², 12/18 эт. в Санкт-Петербурге\" , \"https://www.avito.ru/sankt-peterburg/kvartiry/1-k._kvartira_317m_1218et._2276256205\" , \"26 000 ₽ в месяц\" , \"None\" , \"Туристская ул., 30к1\""
    let printer = Printer(fileName: "/Users/castlelecs/Documents/test.csv")
    
    func test_fill_table() throws {
        try! TableManager(filePath: path).write(content)

        printer.fillTable(with: [])
        let expectedApartment = Apartment(name: "1-к. квартира, 31,7 м², 12/18 эт. в Санкт-Петербурге", url: "https://www.avito.ru/sankt-peterburg/kvartiry/1-k._kvartira_317m_1218et._2276256205", price: "26 000 ₽ в месяц", additionalInfo: nil, address: "Туристская ул., 30к1")

        let apartment = printer.table.pop()

        XCTAssertEqual(expectedApartment, apartment)

        try! FileSystemManager.shared.removeFile(atPath: path)
    }
}
