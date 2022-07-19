//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI
import QIF
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    
    @Environment(\.openURL) var openURL
    
    @State private var isImporting = false
    @State private var isExporting = false
    
    @State private var isLoading = false
    
    @StateObject var records: Records = Records()
    
    @State private var sortOrder: [KeyPathComparator<Record>] = [
        KeyPathComparator(\Record.event.date, order: .forward)
    ]
    
    @State private var selectedRecords = Set<Record.ID>()
    
    @State private var showSuccessfulExportAlert = false
    
    @State private var query = ""
    
    // @State private var newestRecord: String? = nil
    
    var categoryListBinding: Binding<[String]> {
            Binding(get: {
                guard let databaseManager = DB.shared.manager, let categories = databaseManager.categories else { return [] }
                return categories.sorted()
            }, set: { newValue in
                guard let databaseManager = DB.shared.manager else { return }
                
                try? databaseManager.add(categories: newValue)
            })
        }
    
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
    
    var table: some View {
        Table(filteredRecords, selection: $selectedRecords, sortOrder: $sortOrder) {
            TableColumn("Date", value: \Record.event.date) { record in
                
                let dateBinding = Binding {
                    record.event.date
                } set: { newDate in
                    record.event.date = newDate
                }

                
                DatePicker("Date", selection: dateBinding, displayedComponents: [.date])
            }
            
            TableColumn("Check #", value: \Record.event.checkNumber, comparator: OptionalComparator<Int>()) { record in
                
                let checkNumberBinding = Binding {
                    if let checkNumber = record.event.checkNumber {
                        return "\(checkNumber)"
                    } else {
                        return ""
                    }
                } set: { number in
                    record.event.checkNumber = Int(number)
                }
                
                TextField("", text: checkNumberBinding)

            }
            
            TableColumn("Reconciled", value: \Record.event.isReconciled, comparator: BoolComparator()) { record in
                
                let reconciledBinding = Binding {
                    record.event.isReconciled
                } set: { newValue in
                    record.event.isReconciled = newValue
                }

                
                Toggle("", isOn: reconciledBinding)
            }
            
            TableColumn("Category", value: \Record.event.category, comparator: OptionalComparator<String>()) { record in
                
                let categoryBinding = Binding {
                    record.event.category
                } set: { newValue in
                    record.event.category = newValue
                }

                
                OptionalComboBox(selection: categoryBinding, choices: categoryListBinding)
            }
            
            TableColumn("Vendor", value: \Record.event.vendor) { record in
                
                let vendorBinding = Binding {
                    record.event.vendor
                } set: { newVendor in
                    record.event.vendor = newVendor
                }

                
                TextField("", text: vendorBinding)
            }
            
            TableColumn("Memo", value: \Record.event.memo) { record in
                
                let memoBinding = Binding {
                    record.event.memo
                } set: { newMemo in
                    record.event.memo = newMemo
                }

                
                TextField("", text: memoBinding)
            }
            
            TableColumn("Credit", value: \Record.event.amount) { record in
                
                let creditBinding: Binding<Double> = Binding {
                    guard case EventType.deposit = record.event.type else { return 0 }
                    
                    return record.event.amount
                } set: { newAmount in
                    record.event.type = .deposit
                    
                    record.event.amount = newAmount
                }

                
                TextField("", value: creditBinding, formatter: Event.CURRENCY_FORMAT)
            }
            
            TableColumn("Withdrawal", value: \Record.event.amount) { record in
                
                let withdrawalBinding: Binding<Double> = Binding {
                    guard case EventType.withdrawal = record.event.type else { return 0 }
                    
                    return record.event.amount
                } set: { newAmount in
                    record.event.type = .withdrawal
                    
                    record.event.amount = newAmount
                }
                
                TextField("", value: withdrawalBinding, formatter: Event.CURRENCY_FORMAT)
            }
            
            TableColumn("Balance", value: \Record.self) { record in
                
                if let BALANCE_VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: records.balance(for: record))) {
                    Text(BALANCE_VALUE)
                        .foregroundColor(Color.black)
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
                    
                    Button("View Summary") {
                        let summaryURL = URL(string: "bcheckbook://summary")!
                        
                        openURL(summaryURL)
                    }
                }, label: {
                    Text("Options")
                })
                
            }
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    let RECORD = Record()
                    
                    try? add(record: RECORD)
                    
                    // newestRecord = RECORD.id
                    
                }
                
                Button("-") {
                    guard !selectedRecords.isEmpty else { return }
                    
                    if selectedRecords.count > 1 {
                        
                        let recordSelection = records.items.filter { record in
                            selectedRecords.contains(record.id)
                        }
                        
                        Task {
                            try? await remove(records: recordSelection)
                        }
                    } else {
                        if let RECORD = records.items[id: selectedRecords.first!] {
                            try? remove(record: RECORD)
                        }
                    }
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
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFile, .quickenInterchangeFormat], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "bcheck":
                        loadRecords(fromBCheck: file)
                    default:
                        loadRecords(fromQIF: file)
                    }
                }
            }
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "bcheck":
                loadRecords(fromBCheck: fileURL)
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
            
            records.items = storedRecords
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
                loadRecords()
            }
            
        })
    }
    
    func removeRecordsUndoActionRegister(for records: [Record]) {
        undoManager?.registerUndo(withTarget: self.records, handler: { _ in
            
            Task {
                try? await add(records: records)
                
                    loadRecords()
                
            }
            
        })
    }
    
    func removeRecordUndoActionRegister(_ record: Record) {
        
        undoManager?.registerUndo(withTarget: records, handler: { _ in
            
            try? add(record: record)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(records: Records(withRecords: [
            Record()
        ]))
    }
}
