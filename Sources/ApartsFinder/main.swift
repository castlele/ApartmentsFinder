import Foundation
import Core

func main() {
    let ss = SessionService()
    
    ss.setParserDelegate()
    
    ss.parseArguments()
    
    ss.makeNetworkRequest()
    
    ss.makePrinter()
    ss.fillTable()
    try! ss.write()
}

main()
