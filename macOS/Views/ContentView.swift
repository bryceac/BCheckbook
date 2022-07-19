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
    
    @EnvironmentObject var records: Records
    
    @State private var selectedRecords = Set<Record.ID>()
    
    @State private var showSuccessfulExportAlert = false
    
    @State private var query = ""
    
    // @State private var newestRecord: String? = nil
    
    
    
    var body: some View {
        RecordTable(withRecordsToDisplay: filteredRecords, selection: $selectedRecords, filter: $query).environmentObject(records).toolbar(content: {
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
            ToolbarItemGroup(placement: ToolbarItemPlacement.primaryAction) {
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
        ContentView().environmentObject(Records())
    }
}
