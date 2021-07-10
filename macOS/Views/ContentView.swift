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
                        undoManager?.registerUndo(withTarget: records, handler: { storedRecords in
                            storedRecords.remove(at: index)
                        })
                        
                    }
                }))
            }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    undoManager?.registerUndo(withTarget: records, handler: { storedRecords in
                        storedRecords.add(Record())
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
