//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var records: Records = Records()
    
    @State var isExporting = false
    @State var isImporting = false
    
    @State private var showSaveSuccessfulAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(records.sortedRecords) { record in
                    
                    
                        NavigationLink(
                            destination: RecordDetailView(record: record),
                            label: {
                                RecordView(record: record) {
                          getRecord(priorTo: record)
                                }
                            })
                }.onDelete(perform: delete)
            }.toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    
                    Menu(content: {
                        Button("Export Transactions") {
                            isExporting = true
                        }
                        
                        Button("Import Transactions") {
                            isImporting = true
                        }
                    }, label: {
                        Text("Options")
                    })
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
        }.fileExporter(isPresented: $isExporting, document: BCheckFileDocument(records: records), contentType: .bcheckFiles, defaultFilename: "transactions") { result in
            if case .success = result {
                showSaveSuccessfulAlert = true
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFiles], allowsMultipleSelection: false) { result in
            if case .success = result {
                guard let file = try? result.get().first, let loadedRecords = try? Record.load(from: file) else { return }
                
                try? addRecords(loadedRecords)
                loadRecords()
            }
        }.onOpenURL { fileURL in
            guard let savedRecords = try? Record.load(from: fileURL) else { return }
            
            try? addRecords(savedRecords)
            loadRecords()
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
    
    func addRecords(_ records: [Record]) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.add(records: records)
    }
    
    func getRecord(priorTo record: Record) -> Record? {
        var priorRecord: Record? = nil
        
        DispatchQueue.main.async {
            guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records else { return }
            
            priorRecord = storedRecords.element(before: record)
        }
        
        
        return priorRecord
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BCheckFileDocument())
    }
}
