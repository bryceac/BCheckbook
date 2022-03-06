//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI
import QIF

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    
    @Environment(\.openURL) var openURL
    
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var isExportingToQIF = false
    
    @StateObject var records: Records = Records()
    
    @State private var showSuccessfulExportAlert = false
    
    @State private var query = ""
    
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
    
    var body: some View {
        List {
            ForEach(filteredRecords) { record in
                    
                let recordBalance = records.balances[record]!
                    
                RecordView(record: record, balance: recordBalance).contextMenu(ContextMenu(menuItems: {
                        Button("Delete") {
                            try? remove(record: record)
                        }
                    }))
                }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.principal) {
                
                Menu(content: {
                    Button("Import Transactions") {
                        isImporting = true
                    }
                    
                    Button("Export Transactions") {
                        isExporting = true
                    }
                    
                    Button("Export Transactions to QIF") {
                        isExportingToQIF = true
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
        }.fileExporter(isPresented: $isExporting, document: BCheckFileDocument(records: records), contentType: .bcheckFiles, defaultFilename: "transactions") { result in
            if case .success = result {
                DispatchQueue.main.async {
                    showSuccessfulExportAlert = true
                }
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFiles, .quickenInterchangeFormat], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "bcheck":
                        load(bcheck: file) { loadedRecords in
                            try? self.add(records: loadedRecords)
                            
                            self.loadRecords()
                        }
                    default:
                        let loadedRecords = transactions(fromQIF: file)
                        
                        try? self.add(records: loadedRecords)
                        
                        loadRecords()
                    }
                }
            }
        }.fileExporter(isPresented: $isExportingToQIF, document: QIFDocument(records: records), contentType: .quickenInterchangeFormat, defaultFilename: "transactions") { result in
            if case .success = result {
                DispatchQueue.main.async {
                    showSuccessfulExportAlert = true
                }
            }
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "bcheck":
                load(bcheck: fileURL) { loadedRecords in
                    try? self.add(records: loadedRecords)
                    
                    self.loadRecords()
                }
            default:
                let loadedRecords = transactions(fromQIF: fileURL)
                
                try? self.add(records: loadedRecords)
                
                loadRecords()
            }
        }.searchable(text: $query, prompt: "search transactions")
    }
    
    func load(bcheck file: URL, completion: @escaping ([Record]) ->Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let records = try? Record.load(from: file) else { return }
            
            DispatchQueue.main.async {
                completion(records)
            }
        }
    }
    
    func load(qif file: URL, completion: @escaping (QIF) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let qif = try? QIF.load(from: file) else { return }
            
            DispatchQueue.main.async {
                completion(qif)
            }
        }
    }
    
    func transactions(fromQIF file: URL) -> [Record] {
        
        var records = [Record]()
        
        load(qif: file) { qif in
            if let bank = qif.sections[QIFType.bank.rawValue] {
                records = bank.transactions.map {
                    Record(transaction: Event($0))
                }
            }
        }
        
        return records
    }
    
    func loadRecords() {
        guard let databaseManager = DB.shared.manager, let storedRecords = try? databaseManager.records(inRange: .all) else { return }
        
        records.items = storedRecords
    }
    
    func add(record: Record) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.add(record: record)
        
        loadRecords()
        addRecordUndoActionRegister(for: record)
    }
    
    func remove(record: Record) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.remove(record: record)
        
        loadRecords()
        removeRecordUndoActionRegister(record)
    }
    
    func remove(records: [Record]) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.remove(records: records)
        
        loadRecords()
        removeRecordsUndoActionRegister(for: records)
    }
    
    func add(records: [Record]) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.add(records: records)
        
        loadRecords()
        addRecordsUndoActionRegister(for: records)
    }
    
    func addRecordUndoActionRegister(for record: Record) {
        
        undoManager?.registerUndo(withTarget: records, handler: { _ in
            
            try? remove(record: record)
        })
        
    }
    
    func addRecordsUndoActionRegister(for records: [Record]) {
        undoManager?.registerUndo(withTarget: self.records, handler: { _ in
            try? remove(records: records)
        })
    }
    
    func removeRecordsUndoActionRegister(for records: [Record]) {
        undoManager?.registerUndo(withTarget: self.records, handler: { _ in
            try? add(records: records)
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
