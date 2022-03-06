//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI
import QIF

struct ContentView: View {
    
    @StateObject var records: Records = Records()
    
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var isExportingToQIF = false
    
    @State private var showSaveSuccessfulAlert = false
    
    @State private var query = ""
    
    @State private var isLoadingData = false
    
    var filteredRecords: [Record] {
        guard !query.isEmpty else { return records.sortedRecords }
        
        var requestedRecords: [Record] = []
        
        
        switch (query) {
        case let text where text.starts(with: "category:"):
            if let categoryPattern = text.matching(regexPattern: "category:\\s(.*)"), !categoryPattern.isEmpty, categoryPattern[0].indices.contains(1) {
                let specifiedCategory = categoryPattern[0][1]
                
                requestedRecords = records.filter(category: specifiedCategory)
            }
        case let text where text.contains(" category:"):
            if let categoryRange = text.range(of: "category:"), let categoryPattern = text.matching(regexPattern: "category:\\s(.*)"), !categoryPattern.isEmpty, categoryPattern[0].indices.contains(1) {
                let specifiedCategory = categoryPattern[0][1]
                var vendor = String(text[..<categoryRange.lowerBound])
                
                if let lastCharacter = vendor.last, lastCharacter.isWhitespace {
                    vendor = String(vendor.dropLast())
                }
                
                requestedRecords = records.filter(vendor: vendor, category: specifiedCategory)
            }
        default:
            requestedRecords = records.filter(vendor: query)
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
                        
                        Button("Export Transactions to QIF") {
                            isExportingToQIF = true
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
        }.alert("Export Successful", isPresented: $showSaveSuccessfulAlert) {
            Button("Ok") {
                showSaveSuccessfulAlert = false
            }
        } message: {
            Text("Transactions were successfully exported.")
        }.fileExporter(isPresented: $isExporting, document: BCheckFileDocument(records: records), contentType: .bcheckFiles, defaultFilename: "transactions") { result in
            if case .success = result {
                showSaveSuccessfulAlert = true
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFiles, .quickenInterchangeFormat], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "bcheck":
                        load(bcheck: file) { loadedRecords in
                            try? self.addRecords(loadedRecords)
                            
                            self.loadRecords()
                        }
                    default:
                        let loadedRecords = self.transactions(fromQIF: file)
                        
                        try? self.addRecords(loadedRecords)
                        
                        self.loadRecords()
                    }
                }
            }
        }.fileExporter(isPresented: $isExportingToQIF, document: QIFDocument(records: records), contentType: .quickenInterchangeFormat, defaultFilename: "transactions") { result in
            if case .success = result {
                showSaveSuccessfulAlert = true
            }
        }.onOpenURL { fileURL in
            if let loadedRecords = try? Record.load(from: fileURL) {
                
                try? addRecords(loadedRecords)
                loadRecords()
            } else if let loadedQIF = try? QIF.load(from: fileURL), let bank = loadedQIF.sections[QIFType.bank.rawValue] {
                let loadedRecords = bank.transactions.map { Record(transaction: Event($0)) }
                
                try? addRecords(loadedRecords)
                loadRecords()
            }
        }.overlay(ProgressView()
                    .padding().background(Color.white).cornerRadius(10).shadow(radius: 10).opacity(isLoadingData ? 1 : 0)).searchable(text: $query, prompt: "Search transactions").textInputAutocapitalization(.never)
    }
    
    func load(bcheck file: URL, completion: @escaping ([Record]) ->Void) {
        
        isLoadingData = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let records = try? Record.load(from: file) else {
                    isLoadingData = false
                    return
                }
            
            DispatchQueue.main.async {
                self.isLoadingData = false
                completion(records)
            }
        }
    }
    
    func load(qif file: URL, completion: @escaping (QIF) -> Void) {
        
        isLoadingData = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let qif = try? QIF.load(from: file) else {
                isLoadingData = false
                return
            }
            
            DispatchQueue.main.async {
                completion(qif)
            }
        }
    }
    
    func transactions(fromQIF file: URL) -> [Record] {
        
        var records = [Record]()
        
        load(qif: file) { qif in
            if let bank = qif.sections[QIFType.bank.rawValue] {
                records = bank.transactions.map {
                    Record(transaction: Event($0))
                }
            }
        }
        
        isLoadingData = false
        
        return records
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
