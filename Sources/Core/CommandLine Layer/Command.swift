public protocol CLKey: RawRepresentable, CaseIterable {}

public struct Command: Hashable {
    private static var systemCommands: [String] = []
    
    public var cmd: String
    
    public init?(_ cmd: String) {
        guard Self.systemCommands.contains(cmd) else { return nil }
        self.cmd = cmd
    }
    
    public init?(_ index: Int) {
        let strIndex = String(index)
        guard Self.systemCommands.contains(strIndex) else { return nil }
        self.cmd = strIndex
    }
    
    public static func setSessionCommands(_ cmds: [String]) {
        systemCommands = cmds
    }
}
