//
//  SummaryViewModel.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 1/8/22.
//

import Foundation

class SummaryViewModel: ObservableObject {
    @Published var categories: [String]
    
    init(withCategories categories: [String] = []) {
        self.categories = categories
    }
    
    func total(for category: String) -> Double {
        guard let databaseManager = DB.shared.manager, let tallies = databaseManager.totals, let tally = tallies[category] else { return 0 }
        
        return tally
    }
}