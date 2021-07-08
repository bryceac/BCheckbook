//
//  ContentView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var bcheckFile: BCheckFileDocument
    
    var body: some View {
        List {
            ForEach(bcheckFile.records.sortedRecords.indices, id: \.self) { index in
                RecordView(record: bcheckFile.records.sortedRecords[index]).contextMenu(ContextMenu(menuItems: {
                    Button("Delete") {
                        bcheckFile.records.remove(at: index)
                    }
                }))
            }
        }.toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button("+") {
                    bcheckFile.records.add(Record())
                }
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(bcheckFile: .constant(BCheckFile()))
    }
}
