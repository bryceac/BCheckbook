//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI
import QIF
import UniformTypeIdentifiers
import IdentifiedCollections

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    
    @Environment(\.openURL) var openURL
    
    @State private var isImporting = false
    @State private var isExporting = false
    
    @State private var isLoading = false
    
    @StateObject var records: Records = Records()
    
    @State private var selectedRecords = Set<Record.ID>()
    
    @State private var showSuccessfulExportAlert = false
    
    @State private var query = ""
    
    // @State private var newestRecord: String? = nil
    
    
    var filteredRecords: [Record] {
        guard !query.isEmpty else { return records.sortedRecords }
        
        var requestedRecords: [Record] = []
        
        
        switch (query) {
        case let text where text.starts(with: "category:"):
            if let categoryPattern = text.matching(regexPattern: "category:\\s(.*)"), !categoryPattern.isEmpty, categoryPattern[0].indices.contains(1) {
                let specifiedCategory = categoryPattern[0][1]
                
                requestedRecords = records.filter(category: specifiedCategory)
            }
        case let text where text.contains(" category:"):
            if let categoryRange = text.range(of: "category:"), let categoryPattern = text.matching(regexPattern: "category:\\s(.*)"), !categoryPattern.isEmpty, categoryPattern[0].indices.contains(1) {
                let specifiedCategory = categoryPattern[0][1]
                var vendor = String(text[..<categoryRange.lowerBound])
                
                if let lastCharacter = vendor.last, lastCharacter.isWhitespace {
                    vendor = String(vendor.dropLast())
                }
                
                requestedRecords = records.filter(vendor: vendor, category: specifiedCategory)
            }
        default:
            requestedRecords = records.filter(vendor: query)
        }
        
        return requestedRecords
    }
    
    var categoryListBinding: Binding<[String]> {
            Binding(get: {
                guard let databaseManager = DB.shared.manager, let categories = databaseManager.categories else { return [] }
                return categories.sorted()
            }, set: { newValue in
                guard let databaseManager = DB.shared.manager else { return }
                
                try? databaseManager.add(categories: newValue)
            })
        }
    
    var table: some View {
        Table(filteredRecords, selection: $selectedRecords) {
            TableColumn("Date") { record in

                DatePicker("Date", selection: recordBinding(record.id).event.date, displayedComponents: [.date])
            }
            
            TableColumn("Check #") { record in

                TextField("Check No.", text: checkNumberBinding(record.id))

            }
            
            TableColumn("Reconciled") { record in
                
                Toggle("", isOn: recordBinding(record.id).event.isReconciled)
            }
            
            TableColumn("Category") { record in

                OptionalComboBox(selection: recordBinding(record.id).event.category, choices: categoryListBinding)
            }
            
            TableColumn("Vendor") { record in
                
                TextField("Payee", text: recordBinding(record.id).event.vendor)
            }
            
            TableColumn("Memo") { record in
                
                TextField("Description", text: recordBinding(record.id).event.memo)
            }
            
            TableColumn("Credit") { record in
                
                TextField("", value: creditBinding(record.id), formatter: Event.CURRENCY_FORMAT)
            }
            
            TableColumn("Withdrawal") { record in
                
                TextField("", value: withdrawalBinding(record.id), formatter: Event.CURRENCY_FORMAT)
            }
            
            TableColumn("Balance") { record in
                
                if let BALANCE_VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: records.balance(for: record))) {
                    Text(BALANCE_VALUE)
                }
            }
        }
    }
    
    var body: some View {
        table.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.principal) {
                
                Menu(content: {
                    Button("Import Transactions") {
                        isImporting = true
                    }
                    
                    Button("Export Transactions") {
                        
                        records.exportFormat = .bcheckFile
                        
                        isExporting = true
                    }
                    
                    Button("Export Transactions to QIF") {
                        records.exportFormat = .quickenInterchangeFormat
                        
                        isExporting = true
                    }
                    
                    Button("Export Transactions to TSV") {
                        
                        records.exportFormat = .bcheckTSV
                        
                        isExporting = true
                    }

                    Button("View Summary") {
                        let summaryURL = URL(string: "bcheckbook://summary")!
                        
                        openURL(summaryURL)
                    }
                }, label: {
                    Text("Options")
                })
                
            }
            ToolbarItemGroup(placement: ToolbarItemPlacement.primaryAction) {
                
                Button {
                    let RECORD = Record()
                    
                    try? add(record: RECORD)
                } label: {
                    Image(systemName: "plus")
                }
                
                Button {
                    guard !selectedRecords.isEmpty else { return }
                    
                    if selectedRecords.count > 1 {
                        
                        let recordSelection = records.items.filter { record in
                            selectedRecords.contains(record.id)
                        }.map { $0 }
                        
                        Task {
                            try? await remove(records: recordSelection)
                            
                            loadRecords()
                        }
                    } else {
                        if let RECORD = records.items[id: selectedRecords.first!] {
                            try? remove(record: RECORD)
                        }
                    }
                } label: {
                    Image(systemName: "minus")
                }
            }
        }).onAppear(perform: {
            loadRecords()
        }).alert("Export Successful", isPresented: $showSuccessfulExportAlert) {
            Button("Ok") {
                DispatchQueue.main.async {
                    showSuccessfulExportAlert = false
                }
            }
        } message: {
            Text("Transactions were exported successfully")
        }.fileExporter(isPresented: $isExporting, document: BCheckFileDocument(records: records), contentType: records.exportFormat ?? UTType.bcheckFile, defaultFilename: "transactions") { result in
            if case .success = result {
                DispatchQueue.main.async {
                    showSuccessfulExportAlert = true
                }
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFile, .quickenInterchangeFormat, .bcheckTSV], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "bcheck":
                        loadRecords(fromBCheck: file)
                    case "tsv", "txt":
                        loadRecords(fromTSV: file)
                    default:
                        loadRecords(fromQIF: file)
                    }
                }
            }
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "bcheck":
                loadRecords(fromBCheck: fileURL)
            case "tsv", "txt":
                loadRecords(fromTSV: fileURL)
            default:
                loadRecords(fromQIF: fileURL)
            }
        }.overlay(loadingOverlay).searchable(text: $query, prompt: "search transactions")
    }
    
    @ViewBuilder var loadingOverlay: some View {
        if isLoading {
            ZStack {
                Color.black
                
                ProgressView("loading data...").colorScheme(.dark)
            }
            
        }
    }
    
    func records(fromBCheck file: URL) async -> [Record] {
        
        guard let loadedRecords = try? Record.load(from: file) else { return [] }
        
        return loadedRecords
    }
    
    func loadRecords(fromBCheck file: URL) {
        
        isLoading = true
        Task {
            let loadedRecords = await records(fromBCheck: file)
            
            try? await add(records: loadedRecords)
            
            loadRecords()
        }
    }
    
    func records(fromQIF file: URL) async -> [Record] {
        
        guard let qif = try? QIF.load(from: file), let bank = qif.sections[QIFType.bank.rawValue] else { return [] }
        
        let loadedRecords = bank.transactions.map {
            Record(transaction: Event($0))
        }
        
        return loadedRecords
        
    }
    
    func loadRecords(fromQIF file: URL) {
        
        isLoading = true
        Task {
            let loadedRecords = await records(fromQIF: file)
            
            try? await add(records: loadedRecords)
            
            loadRecords()
        }
    }
    
    func records(fromTSV file: URL) async -> [Record] {
        guard let fileData = try? Data(contentsOf: file), let content = String(data: fileData, encoding: .utf8) else { return [Record]() }
        
        let lines = content.components(separatedBy: .newlines)
        
        let loadedRecords = lines.compactMap { line in
            Record(line)
        }
        
        return loadedRecords
    }
    
    func loadRecords(fromTSV file: URL) {
        
        isLoading = true
        Task {
            let loadedRecords = await records(fromTSV: file)
            
            try? await add(records: loadedRecords)
            loadRecords()
        }
    }
    
    func retrieveRecords() async -> [Record] {
        
        guard let databaseManager = DB.shared.manager, let storedRecords = try? databaseManager.records(inRange: .all) else { return [] }
        
        return storedRecords
    }
    
    func loadRecords() {
        
        if !isLoading {
            isLoading.toggle()
        }
        
        Task {
            let storedRecords = await retrieveRecords()
            
            records.items = IdentifiedArrayOf(uniqueElements: storedRecords)
            isLoading = false
        }
    }
    
    func add(record: Record) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        records.add(record)
        
        try databaseManager.add(record: record)
        
        addRecordUndoActionRegister(for: record)
    }
    
    func remove(record: Record) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        records.remove(record)
        
        try databaseManager.remove(record: record)
        
        removeRecordUndoActionRegister(record)
    }
    
    func remove(records: [Record]) async throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.remove(records: records)
        
        removeRecordsUndoActionRegister(for: records)
    }
    
    func add(records: [Record]) async throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.add(records: records)
        
        addRecordsUndoActionRegister(for: records)
    }
    
    func addRecordUndoActionRegister(for record: Record) {
        
        undoManager?.registerUndo(withTarget: records, handler: { _ in
            
            try? remove(record: record)
        })
        
    }
    
    func addRecordsUndoActionRegister(for records: [Record]) {
        undoManager?.registerUndo(withTarget: self.records, handler: { _ in
            
            Task {
                try? await remove(records: records)
                await loadRecords()
            }
            
        })
    }
    
    func removeRecordsUndoActionRegister(for records: [Record]) {
        undoManager?.registerUndo(withTarget: self.records, handler: { _ in
            
            Task {
                try? await add(records: records)
                
                await loadRecords()
                
            }
            
        })
    }
    
    func removeRecordUndoActionRegister(_ record: Record) {
        
        undoManager?.registerUndo(withTarget: records, handler: { _ in
            
            try? add(record: record)
        })
    }
    
    func recordBinding(_ id: Record.ID) -> Binding<Record> {
        var placeholder = Record(withID: "FF04C3DC-F0FE-472E-8737-0F4034C049F0", transaction: Event(date: Date(), checkNumber: 1260, vendor: "Sam Hill Credit Union", memo: "Open Account", amount: 500, type: .deposit, isReconciled: true))
        
        var recordBinding: Binding<Record>!
        
        if var record = records.items[id: id] {
            recordBinding = Binding(get: {
                record
            }, set: { newRecord in
                record = newRecord
            })
        } else {
            recordBinding = Binding(get: {
                placeholder
            }, set: { newRecord in
                placeholder = newRecord
            })
        }
        
        return recordBinding
    }
    
    func checkNumberBinding(_ id: Record.ID) -> Binding<String> {
        
        let record = recordBinding(id)
        
        return Binding {
            if let checkNumber = record.wrappedValue.event.checkNumber {
                return "\(checkNumber)"
            } else {
                return ""
            }
        } set: { newCheckNumber in
            record.wrappedValue.event.checkNumber = Int(newCheckNumber)
        }

    }
    
    func creditBinding(_ id: Record.ID) -> Binding<Double> {
        
        let record = recordBinding(id)
        
        return Binding {
            guard case EventType.deposit = record.wrappedValue.event.type else { return 0 }
            
            return record.wrappedValue.event.amount
            
        } set: { newAmount in
            
            guard newAmount > 0 else { return }
            
            record.wrappedValue.event.type = .deposit
            
            record.wrappedValue.event.amount = newAmount
        }
    }
    
    func withdrawalBinding(_ id: Record.ID) -> Binding<Double> {
        
        let record = recordBinding(id)
        
        return Binding {
            guard case EventType.withdrawal = record.wrappedValue.event.type else { return 0 }
            
            return recordBinding(id).wrappedValue.event.amount
        } set: { newAmount in
            
            guard newAmount > 0 else { return }
            
            record.wrappedValue.event.type = .withdrawal
            
            record.wrappedValue.event.amount = newAmount
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
