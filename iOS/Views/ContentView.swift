//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var records: Records
    var body: some View {
        NavigationView {
            List {
                ForEach(records.sortedRecords.indices, id: \.self) { index in
                    
                    
                        NavigationLink(
                            destination: RecordDetailView(record: records.sortedRecords[index]),
                            label: {
                                RecordView(record: records.sortedRecords[index])
                            })
                }.onDelete(perform: delete)
            }.toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Save") {
                        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        try? records.sortedRecords.save(to: DOCUMENTS_DIRECTORY.appendingPathComponent("transactions").appendingPathExtension("json"))
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                    Button("+") {
                        records.add(Record())
                    }
                }
            })
        }.onAppear() {
            let DOCUMENTS_DIECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            if let SAVED_RECORDS = try? Record.load(from: DOCUMENTS_DIECTORY.appendingPathComponent("transactions").appendingPathExtension("json")) {
                
                for record in SAVED_RECORDS {
                    records.add(record)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            records.remove(at: index)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Records(withRecords: [
        Record()
        ]))
    }
}
