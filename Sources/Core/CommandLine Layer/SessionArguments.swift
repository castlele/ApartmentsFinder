let FILE_NAME_INDEX = Int(SessionArguments.Key.fileName.rawValue)!
let COLUMNS_INDEX = Int(SessionArguments.Key.columns.rawValue)!

public struct SessionArguments: Encodable {
    public enum Key: String, CLKey {
        case fileName = "1"
        case columns = "2"
        case price = "-p"
        case location = "-l"
        case rooms = "-r"
    }
    
    static public let help = SessionArguments(help: true)
    static public let sessionCommands: [String] = Key.allCases.map { $0.rawValue }
    
    public var fileName: String?
    public var columns: [String]?
    public var price: ClosedRange<Double>?
    public var location: String?
    public var rooms: [Int]?
    public var isHelp: Bool
    
    
    public init(
        fileName: String? = nil,
        columns: [String]? = nil,
        price: ClosedRange<Double>? = nil,
        location: String? = nil,
        rooms: [Int]? = nil,
        help: Bool = false
    ) {
        self.fileName = fileName
        self.columns = columns
        self.price = price
        self.location = location
        self.rooms = rooms
        self.isHelp = help
    }
    
    public init(args: [Command: [String]]) throws {
        guard let fileName = args[Command(FILE_NAME_INDEX)!] else {
            throw ParsingError.unexpectedErrorCantFind(cmd: Command(FILE_NAME_INDEX)!)
        }
        
        guard let cols = args[Command(COLUMNS_INDEX)!] else {
            throw ParsingError.unexpectedErrorCantFind(cmd: Command(COLUMNS_INDEX)!)
        }
        
        self.init(
            fileName: fileName.first,
            columns: Self.makeColumns(cols.first!),
            price: try Self.makePrice(args[Command(Key.price.rawValue)!]),
            location: try Self.makeLocation(args[Command(Key.location.rawValue)!]),
            rooms: try Self.makeRooms(args[Command(Key.rooms.rawValue)!])
        )
    }
    
    static private func makeColumns(_ col: String) -> [String] {
        if col.count == 2 {
            return []
        }
        
        let lowerBracketIndex = col.index(after: col.startIndex)
        let upperBracketIndex = col.index(before: col.index(before: col.endIndex))
        let removedBrackets = col[lowerBracketIndex...upperBracketIndex]
        
        let columns = removedBrackets.split(separator: ",").map { String($0) }
        return columns
    }
    
    static private func makePrice(_ p: [String]?) throws -> ClosedRange<Double>? {
        guard let p = p else {
            return nil
        }
        
        var uniqueValues = Set(p)
        
        guard uniqueValues.count <= 2 else {
            throw ParsingError.invalidValuesAmount(cmd: Command("-p")!, values: p)
        }
        
        if uniqueValues.count == 2 {
            let firstStr = uniqueValues.removeFirst()
            guard let firstBound = Double(firstStr) else {
                throw ParsingError.invalidValueFor(cmd: Command("-p")!, value: firstStr)
            }
            
            let secondStr = uniqueValues.removeFirst()
            guard let secondBound = Double(secondStr) else {
                throw ParsingError.invalidValueFor(cmd: Command("-p")!, value: secondStr)
            }
            
            let lowerBound = min(abs(firstBound), abs(secondBound))
            let upperBound = max(abs(firstBound), abs(secondBound))
            return lowerBound...upperBound
        
        } else if uniqueValues.count == 1 {
            let str = uniqueValues.removeFirst()
            guard let bound = Double(str) else {
                throw ParsingError.invalidValueFor(cmd: Command("-p")!, value: str)
            }
            return 0.0...abs(bound)
            
        } else {
            return nil
        }
    }
    
    static private func makeLocation(_ l: [String]?) throws -> String? {
        guard let l = l else {
            return nil
        }
        
        guard l.count == 1 else {
            throw ParsingError.invalidValuesAmount(cmd: Command("-l")!, values: l)
        }
        
        return l.first
    }
    
    static private func makeRooms(_ r: [String]?) throws -> [Int]? {
        guard let r = r else {
            return nil
        }
        
        var uniqueValues = [Int]()
        
        for uniqueValue in Set(r) {
            guard let uniqueValue = Int(uniqueValue) else {
                throw ParsingError.invalidValueFor(cmd: Command("-r")!, value: uniqueValue)
            }
            uniqueValues.append(uniqueValue)
        }
        
        return uniqueValues.sorted(by: <)
    }
}

extension SessionArguments: Equatable {
    public static func == (lhs: SessionArguments, rhs: SessionArguments) -> Bool {
        let isPriceEqual = lhs.price == rhs.price
        let isLocationEqual = lhs.location == rhs.location
        let isRoomsEqual = lhs.rooms == rhs.rooms
        
        return isPriceEqual && isLocationEqual && isRoomsEqual
    }
}
