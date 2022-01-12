//
//  SummaryView.swift
//  BCheckbook (iOS)
//
//  Created by Bryce Campbell on 1/8/22.
//

import SwiftUI

struct SummaryView: View {
    @StateObject var viewModel: SummaryViewModel = SummaryViewModel()
    
    @State private var summaryRange: RecordPeriod = .all
    
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
                    SummaryRowView(title: "Opening Balance", tally: viewModel.categories.contains("Opening Balance") ? viewModel.total(for: "Opening Balance", in: summaryRange) : viewModel.startingBalance(asOf: summaryRange))
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
            guard let records = try? Record.load(from: fileURL) else { return }
            
            addRecords(records)
            loadCategories()
        }
    }
    
    func loadCategories() {
        guard let databaseManager = DB.shared.manager, let categories = databaseManager.categories else { return }
        
        viewModel.categories = categories
        viewModel.categories.append("Uncategorized")
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
