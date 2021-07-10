//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    @ObservedObject var records: Records
    
    var body: some View {
        List {
            ForEach(records.sortedRecords.indices, id: \.self) { index in
                RecordView(record: records.sortedRecords[index]).contextMenu(ContextMenu(menuItems: {
                    Button("Delete") {
                        let REMOVED_RECORD: Record = records.remove(at: index)
                    }
                }))
            }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    records.add(Record())
                    
                    let ADDED_RECORD = records.sortedRecords.last!
                }
            }
        })
    }
    
    func addRecordUndoActionRegister(at index: Int) {
        
        undoManager?.registerUndo(withTarget: records, handler: { _ in
            let REMOVED_RECORD = records.remove(at: index)
            removeRecordUndoActionRegister(REMOVED_RECORD)
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
