/// Responsible for synchronization of table object and table's data in the file
public class Printer {
    public var table: Table<Apartment> = []
    private let fileName: String
    private let tableManager: TableManager
    
    public var delegate: PrinterDelegateProtocol?
    
    public init(fileName: String) async {
        self.fileName = fileName == "default" ? "/Users/castlelecs/Documents/table.csv" : fileName
        self.tableManager = TableManager(filePath: fileName)
        
        await createFileIfNeededAsync()
    }
    
    public init(fileName: String) {
        let actualFileName = fileName == "default" ? "/Users/castlelecs/Documents/table.csv" : fileName
        self.fileName = actualFileName
        self.tableManager = TableManager(filePath: actualFileName)
        
        createFileIfNeeded()
    }
    
    public func assignDelegate(_ d: PrinterDelegateProtocol) {
        self.delegate = d
    }
    
    public func fillTable(with aparts: [Apartment]) async {
        if let fileContent = await readFileContentAsync(), !fileContent.isEmpty {
            let filesApartments = convertFromCSV(fileContent)
            self.table.push(contentsOf: filesApartments + aparts)
            return
        }
        self.table.push(contentsOf: aparts)
        
        delegate?.tableWasFilled(table: table)
    }
    
    public func fillTable(with aparts: [Apartment]) {
        if let fileContent = readFileContent(), !fileContent.isEmpty {
            let filesApartments = convertFromCSV(fileContent)
            self.table.push(contentsOf: filesApartments + aparts)
            return
        }
        self.table.push(contentsOf: aparts)
        
        delegate?.tableWasFilled(table: table)
    }
    
    public func convertFromCSV(_ csv: String) -> [Apartment] {
        var rows = csv.split(separator: "\n")
        rows.removeFirst() // Removes table header
        var apartments = [Apartment]()
        
        for row in rows {
            let apartment = TableManager.convertFromCSV(String(row))
            apartments.append(apartment)
        }
        
        delegate?.readContentFromFile(content: apartments)
        
        return apartments
    }
    
    private func createFileIfNeededAsync() async {
        await tableManager.createFileAsync()
        
        delegate?.fileWasCreated(fileName: fileName)
    }
    
    private func createFileIfNeeded() {
        tableManager.createFile()
        
        delegate?.fileWasCreated(fileName: fileName)
    }
    
    private func readFileContentAsync() async -> String? {
        return await tableManager.readAsync()
    }
    
    private func readFileContent() -> String? {
        return tableManager.read()
    }
    
    public func save() throws {
        let header = Apartment.tableColumns.map { $0.rawValue }
        
        var contentToSave = header.joined(separator: ",") + "\n"
        
        for row in table {
            guard let apartment = row as? Apartment else { print(row); return }
            let csvRow = apartment.convertToCSV()
            contentToSave += csvRow + "\n"
        }
        
        delegate?.apartmentsWereConvertedToCSV(csv: contentToSave)
        
        try tableManager.write(contentToSave)
        
        delegate?.changesWereSavedToFile(content: tableManager.read() ?? "")
    }
    
    /// Saves data from table object to table file
    public func saveAsync() async throws {
        let header = Apartment.tableColumns.map { $0.rawValue }
        
        var contentToSave = header.joined(separator: ",") + "\n"
        
        for row in table {
            guard let apartment = row as? Apartment else { print(row); return }
            let csvRow = apartment.convertToCSV()
            contentToSave += csvRow + "\n"
        }
        
        delegate?.apartmentsWereConvertedToCSV(csv: contentToSave)
        
        try await tableManager.writeAsync(contentToSave)
        
        delegate?.changesWereSavedToFile(content: contentToSave)
    }
}
