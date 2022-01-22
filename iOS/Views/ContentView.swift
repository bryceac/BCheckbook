//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var records: Records = Records()
    
    @State private var isExporting = false
    @State private var isImporting = false
    
    @State private var showSaveSuccessfulAlert = false
    
    @State private var query = ""
    
    var filteredRecords: [Record] {
        guard !query.isEmpty else { return records.sortedRecords }
        
        var requestedRecords: [Record] = []
        
        if query.contains("category:"), let categoryPattern = query.matching(regexPattern: "category:\\s(.*)"), let categoryRange = query.range(of: "category:"), categoryPattern[0].indices.contains(1) {
            let specifiedCategory = categoryPattern[0][1]
            
            requestedRecords = categoryRange.lowerBound == query.startIndex ? records.sortedRecords.filter { record in
                guard let category = record.event.category else { return false }
                
                return category.caseInsensitiveCompare(specifiedCategory) == .orderedSame
            } : records.sortedRecords.filter { record in
                let vendor = query[..<categoryRange.lowerBound]
                guard let category = record.event.category else { return false }
                
                return record.event.vendor.caseInsensitiveCompare(vendor) == .orderedSame &&
                category.caseInsensitiveCompare(specifiedCategory) == .orderedSame
            }
        } else {
            requestedRecords = records.sortedRecords.filter { $0.event.vendor.caseInsensitiveCompare(query) == .orderedSame }
        }
        
        return requestedRecords
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredRecords) { record in
                    
                    let recordBalance = records.balances[record]!
                    
                        NavigationLink(
                            destination: RecordDetailView(record: record),
                            label: {
                                RecordView(record: record, balance: recordBalance)
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
        }.searchable(text: $query, prompt: "Search transactions")
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            guard let databaseManager = DB.shared.manager else { return }
            
                let record = filteredRecords[index]
            
                records.remove(record)
                
                try? databaseManager.remove(record: record)
                
                loadRecords()
        }
    }
    
    func loadRecords() {
        guard let databaseManager = DB.shared.manager, let storedRecords = try? databaseManager.records(inRange: .all) else { return }
        
        records.items = storedRecords
    }
    
    func addRecords(_ records: [Record]) throws {
        guard let databaseManager = DB.shared.manager else { return }
        
        try databaseManager.add(records: records)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BCheckFileDocument())
    }
}
