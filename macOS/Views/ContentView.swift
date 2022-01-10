//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    
    @State private var isImporting = false
    @State private var isExporting = false
    
    @StateObject var records: Records = Records()
    
    @State private var showSuccessfulExportAlert = false
    
    @State private var recordRange: RecordPeriod = .all
    
    var body: some View {
        List {
            Section {
                Picker("", selection: $recordRange) {
                    ForEach(RecordPeriod.allCases, id: \.self) { range in
                        Text(range.rawValue)
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            
            Section {
                ForEach(records.sortedRecords) { record in
                    
                    let recordBalance = records.balances[record]!
                    
                    RecordView(record: record, balance: recordBalance).contextMenu(ContextMenu(menuItems: {
                        Button("Delete") {
                            try? remove(record: record)
                        }
                    }))
                }
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
        }).alert(isPresented: $showSuccessfulExportAlert, content: {
            Alert(title: Text("Export Successful"), message: Text("Transactions were successfully exported"), dismissButton: .default(Text("Ok")))
        }).fileExporter(isPresented: $isExporting, document: BCheckFileDocument(records: records), contentType: .bcheckFiles, defaultFilename: "transactions") { result in
            if case .success = result {
                DispatchQueue.main.async {
                    showSuccessfulExportAlert = true
                }
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFiles], allowsMultipleSelection: false) { result in
            if case .success = result {
                guard let file = try? result.get().first, let loadedRecords = try? Record.load(from: file) else { return }
                
                try? add(records: loadedRecords)
            }
        }.onOpenURL { fileURL in
            guard let importedRecords = try? Record.load(from: fileURL) else { return }
            
            try? add(records: importedRecords)
        }
    }
    
    func loadRecords() {
        guard let databaseManager = DB.shared.manager, let storedRecords = try? databaseManager.records(inRange: recordRange) else { return }
        
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
