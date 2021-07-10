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
                        
                        undoManager?.registerUndo(withTarget: records, handler: { storedRecords in
                            storedRecords.add(REMOVED_RECORD)
                        })
                        
                    }
                }))
            }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    records.add(Record())
                    
                    let ADDED_RECORD = records.sortedRecords.last!
                    
                    undoManager?.registerUndo(withTarget: records, handler: { storedRecords in
                        if let ADDED_RECORD_INDEX = storedRecords.sortedRecords.firstIndex(of: ADDED_RECORD) {
                            storedRecords.remove(at: ADDED_RECORD_INDEX)
                        }
                    })
                    
                }
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
