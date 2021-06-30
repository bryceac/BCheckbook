//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var records: GetRecords
    var body: some View {
        NavigationView {
            List {
                ForEach(records.items.indices, id: \.self) { index in
                    
                    let PREVIOUS_INDEX = index != records.items.startIndex ? records.items.index(before: index) : nil
                    
                    if let PREVIOUS_INDEX = PREVIOUS_INDEX {
                        NavigationLink(
                            destination: EventView(transaction: $records.items[index].event),
                            label: {
                                RecordView(record: records.items[index], previousRecord: records.items[PREVIOUS_INDEX])
                            })
                    } else {
                        NavigationLink(
                            destination: EventView(transaction: $records.items[index].event),
                            label: {
                                RecordView(record: records.items[index])
                            })
                    }
                }.onDelete(perform: delete)
            }.toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Save") {
                        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        try? records.items.save(to: DOCUMENTS_DIRECTORY.appendingPathComponent("transactions").appendingPathExtension("json"))
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                    Button("+") {
                        records.items.append(Record())
                    }
                }
            })
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            records.items.remove(at: index)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GetRecords(withRecords: [
        Record()
        ]))
    }
}
