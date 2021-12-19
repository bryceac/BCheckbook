//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var records: [Record] = []
    
    @State private var showSaveSuccessfulAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(records.indices, id: \.self) { index in
                    
                    
                        NavigationLink(
                            destination: RecordDetailView(record: records[index]),
                            label: {
                                RecordView(record: records[index])
                            })
                }.onDelete(perform: delete)
            }.toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Save") {
                        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        if let _ = try? records.save(to: DOCUMENTS_DIRECTORY.appendingPathComponent("transactions").appendingPathExtension("bcheck")) {
                            showSaveSuccessfulAlert = true
                        }
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                    Button("+") {
                        let record = Record()
                        
                        if let databaseManager = DB.shared.manager {
                            try? databaseManager.add(record: record)
                            
                            loadRecords()
                        }
                    }
                }
            })
        }.onAppear() {
            loadRecords()
        }.alert(isPresented: $showSaveSuccessfulAlert) {
            Alert(title: Text("Save Successful"), message: Text("Transactions were successfully saved"), dismissButton: .default(Text("Ok")))
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            if let databaseManager = DB.shared.manager {
                let record = records[index]
                
                try? databaseManager.remove(record: record)
            }
            
            loadRecords()
        }
    }
    
    func loadRecords() {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records else { return }
        
        records = storedRecords
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
