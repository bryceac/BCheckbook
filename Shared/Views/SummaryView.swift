//
//  SummaryView.swift
//  BCheckbook (iOS)
//
//  Created by Bryce Campbell on 1/8/22.
//

import SwiftUI

struct SummaryView: View {
    @StateObject var viewModel: SummaryViewModel = SummaryViewModel()
    
    var body: some View {
        List {
            Section {
                if viewModel.sortedCategories.contains("Opening Balance") {
                    SummaryRowView(title: "Opening Balance", tally: viewModel.total(for: "Opening Balance"))
                }
            }
            
            Section {
                ForEach(viewModel.sortedCategories.filter({ $0 != "Opening Balance" }), id: \.self) { category in
                    SummaryRowView(title: category, tally: viewModel.total(for: category))
                }
            }
            
            Section {
                SummaryRowView(title: "Current Balance", tally: viewModel.grandTotal)
            }
            
            Section {
                SummaryRowView(title: "Reconciled", tally: viewModel.totalReconciled)
                SummaryRowView(title: "Unreconciled", tally: viewModel.totalUnreconciled)
            }
        }.onAppear {
            loadSummary()
        }.onOpenURL { fileURL in
            <#code#>
        }
    }
    
    func loadSummary() {
        guard let databaseManager = DB.shared.manager, let tallies = databaseManager.totals else { return }
        
        viewModel.categories = tallies.keys.compactMap { $0 }
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
