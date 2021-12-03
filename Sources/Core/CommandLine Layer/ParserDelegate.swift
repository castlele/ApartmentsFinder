import Darwin
public protocol Parser {
    var logger: Logger? { get set }
    
    func onBeginingParsing()
    func onFinishingParsing()
    
    func onBeginingSplitting(_ args: Any)
    func foundRequiredCommands(_ cmds: Any)
    func foundOptionalCommands(_ cmds: Any)
    func onFinishingSplitting(_ args: Any)
    
    func onReturningArguments(_ args: Any)
    
    func onThrowingError(_ err: Error)
}

extension Parser {
    public func onBeginingParsing() {
        logger?.out("Parsing has began")
    }
    
    public func onFinishingParsing() {
        logger?.out("Parsing has ended")
    }
    
    public func onBeginingSplitting(_ args: Any) {
        logger?.out("Starting splitting arguments: \(args)")
    }
    
    public func foundRequiredCommands(_ cmds: Any) {
        logger?.out("Found required commands: \(cmds)")
    }
    
    public func foundOptionalCommands(_ cmds: Any) {
        logger?.out("Founds optional commands: \(cmds)")
    }
    
    public func onFinishingSplitting(_ args: Any) {
        logger?.out("Finishing splitting arguments: \(args)")
    }
    
    public func onReturningArguments(_ args: Any) {
        logger?.out("Returning session arguments: \(args)")
    }
    
    public func onThrowingError(_ err: Error) {
        logger?.out("Error has been thrown: \(err)")
    }
}
