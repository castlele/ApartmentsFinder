import XCTest
import Core

final class TableTests: XCTestCase {
    let data = [
        Apartment(name: "name1", url: "url1", price: "price1", additionalInfo: nil, address: nil),
        Apartment(name: "name2", url: "url2", price: "price2", additionalInfo: nil, address: nil),
        Apartment(name: "name3", url: "url3", price: "price3", additionalInfo: nil, address: nil),
        Apartment(name: "name4", url: "url4", price: "price4", additionalInfo: nil, address: nil),
        Apartment(name: "name5", url: "url5", price: "price5", additionalInfo: nil, address: nil)
    ]
    
    func test_init_table() throws {
        let emptySet = Table<Apartment>()
        
        XCTAssertTrue(emptySet.description == convert_data_to_description([]) && emptySet.count == 0)
        
        let setWithoutRepetitions = Table(data)
        
        XCTAssertTrue(
            setWithoutRepetitions.description == convert_data_to_description() &&
            setWithoutRepetitions.count == data.count)
        
        let dataWithRepetitions = data + [data[data.count - 1]]
        let setWithRepetitions = Table(dataWithRepetitions)
        
        XCTAssertTrue(
            setWithRepetitions.description == convert_data_to_description() &&
            setWithRepetitions.count == data.count)
        
        let dataWithoutLast = data.filter { $0.name != "name5"}
        let setWithFilter = Table(data) { $0.name != "name5" }
        
        XCTAssertTrue(
            setWithFilter.description == convert_data_to_description(dataWithoutLast) &&
            setWithFilter.count == data.count - 1)
    }
    
    func test_insert_at_index() throws {
        var set = Table(data)
        
        set.insert(data[0], at: 0)
        
        XCTAssertEqual(set.count, data.count)
        
        let element = set.pop(data[data.count - 1])!
        set.insert(element, at: 1)
        
        XCTAssertEqual(set.count, data.count)
        XCTAssertEqual(set, Table([data[0], data[4], data[1], data[2], data[3]]))
    }
    
    func test_push() throws {
        var set = Table<Apartment>()
        
        set.push(data[0])
        set.push(data[1])
        
        XCTAssertEqual(set.count, 2)
        
        set.push(data[1])
        
        XCTAssertEqual(set.count, 2)
    }
    
    func test_pop() throws {
        var set = Table(data)
        
        set.pop(data[0])
        
        XCTAssertEqual(set.count, data.count - 1)
        XCTAssertNil(set.pop(data[0]))
        
        let element = set.pop(data[data.count - 1])
        
        XCTAssertEqual(element, data[data.count - 1])
    }
    
    func test_remove_at_index() throws {
        var set = Table(data)
        
        set.remove(at: 0)
        set.remove(at: set.count - 1)
        
        XCTAssertEqual(set.count, data.count - 2)
        XCTAssertEqual(set, Table([data[1], data[2], data[3]]))
    }
    
    private func convert_data_to_description(_ data: [Apartment]? = nil) -> String {
        var strRepr = ""
        
        if let data = data {
            for element in data {
                strRepr += "\(element)\n"
            }
            return strRepr
        }
        for element in self.data {
            strRepr += "\(element)\n"
        }
        return strRepr
    }
}
