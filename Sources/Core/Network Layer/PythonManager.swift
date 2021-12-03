import PythonKit

public struct PythonManager {
    private let directoryPath: String
    
    public init(dirPath: String) {
        self.directoryPath = dirPath
    }
    
    func getRequestFunction(logger: Logger? = nil) -> PythonObject {
        changeDirectory()
        
        let network = Python.import("network")
        
        return network
    }
    
    private func changeDirectory() {
        let sys = Python.import("sys")
        sys.path.append(directoryPath)
    }
}
