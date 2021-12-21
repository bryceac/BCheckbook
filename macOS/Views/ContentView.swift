//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    
    @StateObject var records: Records = Records()
    
    var body: some View {
        List {
            ForEach(records.sortedRecords) { record in
                RecordView(record: record).contextMenu(ContextMenu(menuItems: {
                    Button("Delete") {
                        records.remove(record)
                        
                        removeRecordUndoActionRegister(record)
                    }
                }))
            }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    let RECORD = Record()
                    
                    records.add(RECORD)
                    
                    if let RECORD_INDEX = records.items.firstIndex(of: RECORD) {
                        addRecordUndoActionRegister(at: RECORD_INDEX)
                    }
                    
                    
                }
            }
        })
    }
    
    func loadRecords() {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records else { return }
        
        records.items = storedRecords
    }
    
    func addRecords(_ records: [Record]) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.add(records: records)
    }
    
    func addRecordUndoActionRegister(at index: Int) {
        
        undoManager?.registerUndo(withTarget: records, handler: { _ in
            let RECORD = records.sortedRecords[index]
            
            records.remove(RECORD)
            removeRecordUndoActionRegister(RECORD)
        })
        
    }
    
    func removeRecordUndoActionRegister(_ record: Record) {
        
        undoManager?.registerUndo(withTarget: records, handler: { _ in
            records.add(record)
            
            if let RECORD_INDEX = records.sortedRecords.firstIndex(of: record) {
                
                addRecordUndoActionRegister(at: RECORD_INDEX)
            }
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
