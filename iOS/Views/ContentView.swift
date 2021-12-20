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
                ForEach(records.sortedRecords) { record in
                    
                    
                        NavigationLink(
                            destination: RecordDetailView(record: record),
                            label: {
                                RecordView(record: record)
                            })
                }.onDelete(perform: delete)
            }.toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Export") {
                        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        if let _ = try? records.items.save(to: DOCUMENTS_DIRECTORY.appendingPathComponent("transactions").appendingPathExtension("bcheck")) {
                            showSaveSuccessfulAlert = true
                        }
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                    Button("+") {
                        let record = Record()
                        
                        records.add(record)
                        
                        if let databaseManager = DB.shared.manager {
                            try? databaseManager.add(record: record)
                        }
                    }
                }
            })
        }.onAppear() {
            loadRecords()
        }.alert(isPresented: $showSaveSuccessfulAlert) {
            Alert(title: Text("Export Successful"), message: Text("Transactions were successfully Exported"), dismissButton: .default(Text("Ok")))
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            if let databaseManager = DB.shared.manager {
                let record = records.items[index]
                
                try? databaseManager.remove(record: record)
            }
            
            loadRecords()
        }
    }
    
    func loadRecords() {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records else { return }
        
        records.items = storedRecords
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Records())
    }
}
