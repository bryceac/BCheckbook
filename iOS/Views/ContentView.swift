//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var records: Records
    
    @State private var showSaveSuccessfulAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(records.items.indices, id: \.self) { index in
                    
                    
                        NavigationLink(
                            destination: RecordDetailView(record: records.items[index]),
                            label: {
                                RecordView(record: records.items[index])
                            })
                }.onDelete(perform: delete)
            }.toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Save") {
                        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        if let _ = try? records.items.save(to: DOCUMENTS_DIRECTORY.appendingPathComponent("transactions").appendingPathExtension("bcheck")) {
                            showSaveSuccessfulAlert = true
                        }
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                    Button("+") {
                        records.add(Record())
                        
                        if let databaseManager = DB.shared.manager, let record = records.items.last {
                            do {
                                try databaseManager.add(record: record)
                            } catch (let error) {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            })
        }.onAppear() {
            if let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records {
                records.items = storedRecords
            }
        }.alert(isPresented: $showSaveSuccessfulAlert) {
            Alert(title: Text("Save Successful"), message: Text("Transactions were successfully saved"), dismissButton: .default(Text("Ok")))
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            if let databaseManager = DB.shared.manager {
                let record = records.items[index]
                
                try? databaseManager.remove(record: record)
            }
            
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
