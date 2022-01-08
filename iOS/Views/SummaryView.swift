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
            ForEach(viewModel.categories, id: \.self) { category in
                HStack {
                    Text(category).bold()
                    if let totalValue = Event.CURRENCY_FORMAT.string(from: NSNumber(value: viewModel.total(for: category))) {
                        Text(totalValue)
                    }
                }
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
