//
//  SummaryView.swift
//  BCheckbook (iOS)
//
//  Created by Bryce Campbell on 1/8/22.
//

import SwiftUI
import QIF

struct SummaryView: View {
    @StateObject var viewModel: SummaryViewModel = SummaryViewModel()
    
    @State private var summaryRange: RecordPeriod = .all
    
    @State private var isLoading = false
    
    var body: some View {
        List {
            Section {
                Picker("", selection: $summaryRange) {
                    ForEach(RecordPeriod.allCases, id: \.self) { range in
                        Text(range.rawValue)
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            Section {
                if case .all = summaryRange {
                    SummaryRowView(title: "Opening Balance", tally: viewModel.total(for: "Opening Balance", in: summaryRange) > 0 ? viewModel.total(for: "Opening Balance", in: summaryRange) : viewModel.startingBalance(asOf: summaryRange))
                } else {
                    SummaryRowView(title: "Opening Balance", tally: viewModel.startingBalance(asOf: summaryRange))
                }
            }
            
            Section {
                ForEach(viewModel.sortedCategories.filter({ $0 != "Opening Balance" }), id: \.self) { category in
                    SummaryRowView(title: category, tally: viewModel.total(for: category, in: summaryRange))
                }
            }
            
            Section {
                SummaryRowView(title: "Balance", tally: viewModel.balance(asOf: summaryRange))
            }
            
            Section {
                SummaryRowView(title: "Total Income", tally: viewModel.total(of: .deposit, for: summaryRange))
                SummaryRowView(title: "Total Expenditures", tally: viewModel.total(of: .withdrawal, for: summaryRange))
            }
            
            Section {
                SummaryRowView(title: "Reconciled", tally: viewModel.total(ofReconciled: true, in: summaryRange))
                
                SummaryRowView(title: "Unreconciled", tally: viewModel.total(ofReconciled: false, in: summaryRange))
            }
        }.onAppear {
            loadCategories()
        }.onOpenURL { fileURL in
            switch fileURL.pathExtension {
            case "bcheck":
                load(fromBCheck: fileURL)
            default:
                load(fromQIF: fileURL)
            }
        }.overlay(loadingOverlay)
    }
    
    @ViewBuilder var loadingOverlay: some View {
        
        if isLoading {
            ZStack {
                Color.black
                
                ProgressView("loading data...").preferredColorScheme(.dark)
            }
        }
    }
    
    func retrieveCategories() async -> [String] {
        guard let databaseManager = DB.shared.manager, var categories = databaseManager.categories else { return [] }
        
        categories.append("Uncategorized")
        
        return categories
    }
    
    func loadCategories() {
        
        if !isLoading {
            isLoading.toggle()
        }
        
        Task {
            let categories = await retrieveCategories()
            
            viewModel.categories = categories
            
            isLoading = false
        }
    }
    
    func records(fromBCheck file: URL) async -> [Record] {
        
        guard let records = try? Record.load(from: file) else { return [] }
        
        return records
    }
    
    func load(fromBCheck file: URL) {
        isLoading = true
        Task {
            let records = await records(fromBCheck: file)
            
            addRecords(records)
            loadCategories()
        }
    }
    
    func records(fromQIF file: URL) async -> [Record] {
        guard let qif = try? QIF.load(from: file), let bank = qif.sections[QIFType.bank.rawValue] else { return [] }
        
        return bank.transactions.map {
            Record(transaction: Event($0))
        }
    }
    
    func load(fromQIF file: URL) {
        
        isLoading = true
        Task {
            let records = await records(fromQIF: file)
            
            addRecords(records)
            loadCategories()
        }
    }
    
    private func addRecords(_ records: [Record]) {
        guard let databaseManager = DB.shared.manager else { return }
        
        try? databaseManager.add(records: records)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
