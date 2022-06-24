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
    
    @State private var isLoading = false
    
    @State private var showSaveSuccessfulAlert = false
    
    @State private var query = ""
    
    @State var newestRecord: String? = nil
    
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
            ScrollViewReader { proxy in
                List {
                    ForEach(filteredRecords) { record in
                        
                        let recordBalance = records.balance(for: record)
                        
                            NavigationLink(
                                destination: RecordDetailView(record: record),
                                label: {
                                    RecordView(record: record, balance: recordBalance)
                                }).id(record.id)
                    }.onDelete(perform: delete)
                }.toolbar(content: {
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                        
                        Menu(content: {
                            Button("Export Transactions") {
                                
                                records.exportFormat = .bcheckFile
                                
                                isExporting = true
                            }
                            
                            Button("Export Transactions to QIF") {
                                
                                records.exportFormat = .quickenInterchangeFormat
                                
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
                        Button(action: {
                            let record = Record()
                            
                            records.add(record)
                            
                            if let databaseManager = DB.shared.manager {
                                try? databaseManager.add(record: record)
                                
                                newestRecord = record.id
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }).onChange(of: newestRecord) { record in
                    proxy.scrollTo(newestRecord, anchor: .top)
                }
            }
        }.onAppear() {
            loadRecords()
        }.alert("Export Successful", isPresented: $showSaveSuccessfulAlert) {
            Button("Ok") {
                showSaveSuccessfulAlert = false
            }
        } message: {
            Text("Transactions were successfully exported.")
        }.fileExporter(isPresented: $isExporting, document: BCheckFileDocument(records: records), contentType: records.exportFormat ?? .bcheckFile, defaultFilename: "transactions") { result in
            if case .success = result {
                showSaveSuccessfulAlert = true
            }
        }.fileImporter(isPresented: $isImporting, allowedContentTypes: [.bcheckFile, .quickenInterchangeFormat], allowsMultipleSelection: false) { result in
            if case .success = result {
                if let file = try? result.get().first {
                    
                    switch file.pathExtension {
                    case "bcheck":
                        loadRecords(fromBCheck: file)
                    default:
                        loadRecords(fromQIF: file)
                    }
                }
            }
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "bcheck":
                loadRecords(fromBCheck: fileURL)
            default:
                loadRecords(fromQIF: fileURL)
            }
        }.overlay(loadingOverlay).searchable(text: $query, prompt: "Search transactions").textInputAutocapitalization(.never)
    }
    
    @ViewBuilder var loadingOverlay: some View {
        
        if isLoading {
            ZStack {
                Color.black
                
                ProgressView("loading data...").preferredColorScheme(.dark)
            }
        }
    }
    
    func records(fromBCheck file: URL) async -> [Record] {
        
        guard let loadedRecords = try? Record.load(from: file) else { return [] }
        
        return loadedRecords
    }
    
    func loadRecords(fromBCheck file: URL) {
        
        isLoading = true
        Task {
            let loadedRecords = await records(fromBCheck: file)
            
            try? addRecords(loadedRecords)
            loadRecords()
        }
    }
    
    func records(fromQIF file: URL) async -> [Record] {
        
        guard let qif = try? QIF.load(from: file), let bank = qif.sections[QIFType.bank.rawValue] else { return [] }
        
        let loadedRecords = bank.transactions.map {
            Record(transaction: Event($0))
        }
        
        return loadedRecords
        
    }
    
    func loadRecords(fromQIF file: URL) {
        
        isLoading = true
        Task {
            let loadedRecords = await records(fromQIF: file)
            
            try? addRecords(loadedRecords)
            loadRecords()
        }
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
    
    func retrieveRecords() async -> [Record] {
        
        guard let databaseManager = DB.shared.manager, let storedRecords = try? databaseManager.records(inRange: .all) else { return [] }
        
        return storedRecords
    }
    
    func loadRecords() {
        if !isLoading {
            isLoading.toggle()
        }
        
        Task {
            let storedRecords = await retrieveRecords()
            
            records.items = storedRecords
            
            isLoading = false
        }
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
