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
                        let RECORD = records.sortedRecords[index]
                        
                        records.remove(RECORD)
                    }
                }))
            }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    let RECORD = Record()
                    
                    records.add(RECORD)
                    
                    
                }
            }
        })
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
