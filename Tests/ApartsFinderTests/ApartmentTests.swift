import XCTest
import Core

final class ApartmentTests: XCTestCase {
    func test_convert_to_csv() throws {
        let apartment = Apartment(name: "hata", url: "http://blabal.com", price: "15000", additionalInfo: nil, address: nil)
        
        let expectedCSV = "hata,http://blabal.com,15000,None,None"
        
        XCTAssertEqual(apartment.convertToCSV(), expectedCSV)
    }
}
