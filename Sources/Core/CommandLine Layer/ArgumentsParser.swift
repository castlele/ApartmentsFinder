// MARK: - Arguments Parser
/// Helper object for parsing arguments from Command Line
public class ArgumentsParser: Parser {
    private var store = LinkedList()
    private var globalPointer: Node?
    public var logger: Logger? = StandardCLLogger()
    public var delegate: Parser?
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public init() {}
    
    /// Parses array of strings to concrete arguments.
    /// - Parameter args: Array of strings. Should be taken from `CommandLine.arguments`
    /// - Returns: Object, wich should be conform to protocol `ArgumentsConvertable`.
    /// This object should contain info about all arguments of the application.
    public func parse(_ args: [String]) throws -> SessionArguments {
        defer {
            store.clear()
            delegate?.onFinishingParsing()
        }
        delegate?.onBeginingParsing()
        
        if let helpArgument = fillLinkedList(with: args) {
            delegate?.onReturningArguments(helpArgument)
            return helpArgument
        }
        
        guard isEnoughArgs() else {
            let error = ParsingError.notEnoughtArgs
            delegate?.onThrowingError(error)
            throw error
        }
        
        let commands = try split()
        let sessionArguments = try SessionArguments(args: commands)
        
        delegate?.onReturningArguments(sessionArguments)
        
        return sessionArguments
    }
    
    private func fillLinkedList(with args: [String]) -> SessionArguments? {
        for arg in args {
            if isHelp(arg) {
                return SessionArguments.help
            }
            store.append(arg)
        }
        return nil
    }
    
    private func isHelp(_ arg: String) -> Bool { arg.contains("-help") }
    
    private func isEnoughArgs() -> Bool {
        store.size >= 3 ? true : false
    }
    
    
    /// Split array of strings into dictionary, that can be used to initialize arguments object.
    /// - Parameter args: Array of strings. Should be taken from `CommandLine.arguments`
    /// - Returns: Dictionary where key represents command line argument (property) and value represents array of values.
    private func split() throws -> [Command: [String]] {
        delegate?.onBeginingSplitting(store)
        let requiredCommands = try getRequiredCommands()
        delegate?.foundRequiredCommands(requiredCommands)
        let optionalCommands = try getOptionalCommands()
        delegate?.foundOptionalCommands(optionalCommands)
        
        let commands = requiredCommands.merging(optionalCommands) { (command, _) in command }
        
        delegate?.onFinishingSplitting(commands)
        return commands
    }
    
    private func getRequiredCommands() throws -> [Command: [String]] {
        let fileNamePtr = store.head!.next!
        let columnsPtr = fileNamePtr.next!
        
        guard isValidRequiredArgument(fileNamePtr.value, byIndex: FILE_NAME_INDEX), let fileName = Command(FILE_NAME_INDEX) else {
            let error = ParsingError.invalidArgument(index: FILE_NAME_INDEX, arg: fileNamePtr.value)
            delegate?.onThrowingError(error)
            throw error
        }
        
        guard isValidRequiredArgument(columnsPtr.value, byIndex: COLUMNS_INDEX), let columns = Command(COLUMNS_INDEX) else {
            let error = ParsingError.invalidArgument(index: COLUMNS_INDEX, arg: columnsPtr.value)
            delegate?.onThrowingError(error)
            throw error
        }
        
        globalPointer = columnsPtr.next
        return [fileName: [fileNamePtr.value], columns: [columnsPtr.value]]
    }
    
    private func isValidRequiredArgument(_ arg: String, byIndex i: Int) -> Bool {
        switch i {
            case 1:
                return arg.contains(".") || arg.contains("default")
            case 2:
                return arg.first == "["  && arg.last == "]"
            default:
                return false
        }
    }
    
    private func getOptionalCommands() throws -> [Command: [String]] {
        guard let globalPointer = globalPointer else {
            return [:] // There is no optional argumets
        }

        guard let curCmd = Command(globalPointer.value) else {
            let error = ParsingError.invalidArgument(index: 3, arg: globalPointer.value)
            delegate?.onThrowingError(error)
            throw error
        }
        
        var currentPointer: Node? = globalPointer
        var commands = [Command: [String]]()
        
        var currentCmd = curCmd
        
        while let _ = self.globalPointer {
            commands[currentCmd] = []
            
            while let cur = currentPointer {
                if cur.value.hasPrefix("-") {
                    if let command = Command(cur.value) {
                        currentCmd = command
                        self.globalPointer = cur.next
                        currentPointer = cur.next
                        break
                    }
                    let error = ParsingError.invalidCommandName(cmd: cur.value)
                    delegate?.onThrowingError(error)
                    throw error
                }
                commands[currentCmd]!.append(cur.value)
                currentPointer = cur.next
                self.globalPointer = cur.next
            }
        }
        
        return commands
    }
}

fileprivate class Node {
    var value: String
    var next: Node?
    
    init(_ value: String) {
        self.value = value
        self.next = nil
    }
}

// MARK: - LinkedList
public struct LinkedList: ExpressibleByArrayLiteral {
    fileprivate var head: Node?
    fileprivate var size: Int
    
    public init(_ arr: [String]) {
        if arr.isEmpty {
            self.head = nil
            self.size = 0
            return
        }
        
        self.head = nil
        self.size = 0
        
        for element in arr {
            append(element)
        }
    }
    
    public init(arrayLiteral elements: String...) {
        if elements.isEmpty {
            self.head = nil
            self.size = 0
            return
        }
        
        self.head = nil
        self.size = 0
        
        for element in elements {
            append(element)
        }
    }
    
    mutating func append(_ element: String) {
        let newNode = Node(element)
        
        if head == nil {
            head = newNode
            size += 1
            return
        }
        
        var currentNode = head
        
        while let cur = currentNode?.next {
            currentNode = cur
        }
        
        currentNode?.next = newNode
        size += 1
    }
    
    mutating func clear() {
        self.head = nil
        self.size = 0
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        guard let head = head else { return "" }
        var strRepr = ""
        var cur = head
        strRepr += cur.value
        
        while let c = cur.next {
            strRepr += " -> " + c.value
            cur = c
        }
        return strRepr
    }
}
