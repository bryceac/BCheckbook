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
                switch summaryRange {
                case .all:
                    if viewModel.categories.contains("Opening Balance") {
                        SummaryRowView(title: "Opening Balance", tally: viewModel.total(for: "Opening Balance", in: .all))
                    } else {
                        SummaryRowView(title: "Opening Balance", tally: viewModel.startingBalance)
                    }
                case .week:
                    SummaryRowView(title: "Opening Balance", tally: viewModel.startingBalanceForWeek)
                case .month:
                    SummaryRowView(title: "Opening Balance", tally: viewModel.startingBalanceForMonth)
                case .threeMonths:
                    SummaryRowView(title: "Opening Balance", tally: viewModel.startingBalanceForQuarter)
                case .sixMonths:
                    SummaryRowView(title: "Opening Balance", tally: viewModel.startingBalanceForSixMonths)
                case .year:
                    SummaryRowView(title: "Opening Balance", tally: viewModel.startingBalanceForYear)
                }
            }
            
            Section {
                ForEach(viewModel.sortedCategories.filter({ $0 != "Opening Balance" }), id: \.self) { category in
                    SummaryRowView(title: category, tally: viewModel.total(for: category, in: summaryRange))
                }
            }
            
            Section {
                switch summaryRange {
                case .all:
                    SummaryRowView(title: "Current Balance", tally: viewModel.grandTotal)
                case .week:
                    SummaryRowView(title: "Current Balance", tally: viewModel.totalForWeek)
                case .month:
                    SummaryRowView(title: "Current Balance", tally: viewModel.totalForMonth)
                case .threeMonths:
                    SummaryRowView(title: "Current Balance", tally: viewModel.totalForQuarter)
                case .sixMonths:
                    SummaryRowView(title: "Current Balance", tally: viewModel.totalForSixMonths)
                case .year:
                    SummaryRowView(title: "Current Balance", tally: viewModel.totalForYear)
                }
            }
            
            Section {
                switch summaryRange {
                case .all:
                    SummaryRowView(title: "Reconciled", tally: viewModel.totalReconciled)
                    SummaryRowView(title: "Unreconciled", tally: viewModel.totalUnreconciled)
                case .week:
                    SummaryRowView(title: "Reconciled", tally: viewModel.totalReconciledForWeek)
                    SummaryRowView(title: "Unreconciled", tally: viewModel.totalUnreconciledForWeek)
                case .month:
                    SummaryRowView(title: "Reconciled", tally: viewModel.totalReconciledForMonth)
                    SummaryRowView(title: "Unreconciled", tally: viewModel.totalUnreconciledForMonth)
                case .threeMonths:
                    SummaryRowView(title: "Reconciled", tally: viewModel.totalReconciledForQuarter)
                    SummaryRowView(title: "Unreconciled", tally: viewModel.totalUnreconciledForQuarter)
                case .sixMonths:
                    SummaryRowView(title: "Reconciled", tally: viewModel.totalReconciledForSixMonths)
                    SummaryRowView(title: "Unreconciled", tally: viewModel.totalUnreconciledForSixMonths)
                case .year:
                    SummaryRowView(title: "Reconciled", tally: viewModel.totalReconciledForYear)
                    SummaryRowView(title: "Unreconciled", tally: viewModel.totalUnreconciledForYear)
                }
            }
        }.onAppear {
            loadSummary()
        }.onOpenURL { fileURL in
            guard let records = try? Record.load(from: fileURL) else { return }
            
            addRecords(records)
            loadSummary()
        }
    }
    
    func loadSummary() {
        guard let databaseManager = DB.shared.manager, let tallies = databaseManager.totals(for: summaryRange) else { return }
        
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
