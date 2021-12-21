//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    
    @State var isImporting = false
    @State var isExporting = false
    
    @StateObject var records: Records = Records()
    
    @State var showSuccessfulExportAlert = false
    
    var body: some View {
        List {
            ForEach(records.sortedRecords) { record in
                RecordView(record: record).contextMenu(ContextMenu(menuItems: {
                    Button("Delete") {
                        try? remove(record: record)
                    }
                }))
            }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    let RECORD = Record()
                    
                    try? add(record: RECORD)
                }
            }
        }).fileExporter(isPresented: $isExporting, document: BCheckFileDocument(records: records), contentType: .bcheckFiles, defaultFilename: "transaction") { result in
            if case .success = result {
                showSuccessfulExportAlert = true
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFiles], allowsMultipleSelection: false) { result in
            if case .success = result {
                guard let file = try? result.get().first, let loadedRecords = try? Record.load(from: file) else { return }
                
                try? add(records: loadedRecords)
            }
        }
    }
    
    func loadRecords() {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records else { return }
        
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
