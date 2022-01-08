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
        }
    }
    
    func loadCategories() {
        guard let databaseManager = DB.shared.manager, let categories = databaseManager.categories
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
