import PythonKit

public struct NetworkRequester {
    private let logger: Logger?
    
    public init(logger: Logger? = nil) {
        self.logger = logger
    }
    
    public func makeRequest(args: SessionArguments) -> [Apartment]? {
        defer {
            logger?.out("Finished proccessing result from the network request")
        }
        
        logger?.out("Start making network request")
        
        guard let data = encodeArguments(args) else {
            logger?.out("Can't encode arguments successfully")
            return nil
        }
        
        let pyManager = Self.makePyManager()
        
        let network = pyManager.getRequestFunction()
        let json = network.request(data)
        
        logger?.out("Got result from network request: \(json)")
        let decodedApartments = decodeApartments(json)
        
        logger?.out("Decoding json successfully: \(String(describing: decodedApartments))")
        return decodedApartments
    }
    
    private static func makePyManager() -> PythonManager {
        let dir = "/Users/castlelecs/Documents/Projects/ApartsFinder/Sources/Python"
        let pyManager = PythonManager(dirPath: dir)
        return pyManager
    }
    
    private func encodeArguments(_ args: SessionArguments) -> String? {
        guard let data = Encoder.encode(args, logger: logger) else {
            return nil
        }
        return data
    }
    
    private func decodeApartments(_ json: PythonObject) -> [Apartment]? {
        let strJson = String(json)!
        let data = strJson.data(using: .utf8)!
        guard let apartments = Decoder.decode(data: data, logger: logger) else {
            return nil
        }
        return apartments
    }
}
