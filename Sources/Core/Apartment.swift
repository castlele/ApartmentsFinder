import Foundation

public struct Apartment: Identifiable, Decodable {
    public static var tableColumns: [CodingKeys] { CodingKeys.allCases }
    
    public let id = UUID()
    
    public var name: String?
    public var url: String?
    public var price: String?
    public var additionalInfo: String?
    public var address: String?
    
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        case url
        case price
        case additionalInfo = "additional_info"
        case address
    }
    
    private var wrappedName: String { name ?? "None" }
    private var wrappedUrl: String { url ?? "None" }
    private var wrappedPrice: String { price ?? "None" }
    private var wrappedAdditionalInfo: String { additionalInfo ?? "None" }
    private var wrappedAddress: String { address ?? "None" }
    
    public init(
        name: String? = nil,
        url: String? = nil,
        price: String? = nil,
        additionalInfo: String? = nil,
        address: String? = nil) {
        self.name = name
        self.url = url
        self.price = price
        self.additionalInfo = additionalInfo
        self.address = address
    }
    
    public func convertToCSV() -> String {
        "\"\(wrappedName)\" , \"\(wrappedUrl)\" , \"\(wrappedPrice)\" , \"\(wrappedAdditionalInfo)\" , \"\(wrappedAddress)\""
    }
}

extension Apartment: CustomStringConvertible {
    public var description: String {
        "| \(wrappedName) | \(wrappedUrl) | \(wrappedPrice) | \(wrappedAdditionalInfo) | \(wrappedAddress) |"
    }
}

extension Apartment: Hashable { }

extension Apartment: Equatable {
    public static func == (lhs: Apartment, rhs: Apartment) -> Bool {
        let isName = lhs.name == rhs.name
        let isURL = lhs.url == rhs.url
        let isPrice = lhs.price == rhs.price
        let isAdditionalInfo = lhs.additionalInfo == rhs.additionalInfo
        let isAddresss = lhs.address == rhs.address
        
        return isName && isURL && isPrice && isAdditionalInfo && isAddresss
    }
}
