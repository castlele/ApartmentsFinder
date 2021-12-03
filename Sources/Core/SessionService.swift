import Darwin
public class SessionService {
    private let logger: Logger
    private let parser: ArgumentsParser
    private var printer: Printer?
    
    public private(set) var sessionArguments: SessionArguments
    public private(set) var apartments: [Apartment] = []
    
    public init() {
        self.sessionArguments = SessionArguments()
        self.logger = StandardCLLogger()
        self.parser = ArgumentsParser(logger: logger)
    }
    
    public func setParserDelegate() { parser.delegate = parser }
    
    public func parseArguments(_ args: [String] = CommandLine.arguments) {
        setSessionCommands()
        
        do {
            sessionArguments = try parser.parse(args)
            
        } catch {
            logger.out(error)
        }
    }
    
    private func setSessionCommands() {
        Command.setSessionCommands(SessionArguments.sessionCommands)
    }
    
    public func makeNetworkRequest() {
        guard !sessionArguments.isHelp else {
            logger.out("afind <file_name:value> <column names:[value]> <arguments> <names of sites:[value]>")
            exit(0)
        }
        let requester = NetworkRequester(logger: logger)
        
        guard let apartmensts = requester.makeRequest(args: sessionArguments) else {
            return
        }
        
        self.apartments = apartmensts
    }
    
    public func makePrinter() {
        self.printer = Printer(fileName: sessionArguments.fileName!)
        printer?.assignDelegate(PrinterDelegate(logger: logger))
    }
    
    public func fillTable() {
        self.printer?.fillTable(with: apartments)
    }
    
    public func write() throws {
        try printer?.save()
    }
}
