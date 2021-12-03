import Foundation

public struct Encoder {
    static func encode<T: Encodable>(_ value: T, logger: Logger? = nil) -> String? {
        do {
            let json = try JSONEncoder().encode(value)
            return String(data: json, encoding: .utf8)
            
        } catch {
            logger?.out("Error while encoding arguments: \(error)")
            return nil
        }
    }
}

public struct Decoder {
    static func decode(data: Data, logger: Logger? = nil) -> [Apartment]? {
        do {
            let json = try JSONDecoder().decode([Apartment].self, from: data)
            return json
            
        } catch {
            logger?.out("Error while decoding apartments: \(error)")
            return nil
        }
    }
}
