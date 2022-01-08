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
                SummaryRowView(title: "Opening Balance", tally: viewModel.total(for: "OpeningBalance"))
            }
            ForEach(viewModel.categories, id: \.self) { category in
                SummaryRowView(title: category, tally: viewModel.total(for: category))
            }
        }.onAppear {
            loadSummary()
        }
    }
    
    func loadSummary() {
        guard let databaseManager = DB.shared.manager, let tallies = databaseManager.totals else { return }
        
        viewModel.categories = tallies.keys.compactMap { $0 }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}