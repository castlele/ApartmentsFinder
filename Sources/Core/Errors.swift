public enum ParsingError: Error {
    case notArg(arg: String)
    case notEnoughtArgs
    case invalidArgument(index: Int, arg: String)
    case unexpectedErrorCantFind(cmd: Command)
    case invalidValuesAmount(cmd: Command, values: [String])
    case invalidValueFor(cmd: Command, value: String)
    case invalidCommandName(cmd: String)
}

public enum FileError: Error {
    case creationFailure
}

public enum CSVTableError: Error {
    case invalidRowSize(expected: Int, given: Int)
}
