//
//  SummaryViewModel.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 1/8/22.
//

import Foundation

class SummaryViewModel: ObservableObject {
    @Published var categories: [String]
    
    var sortedCategories: [String] {
        return categories.sorted(by: <)
    }
    
    init(withCategories categories: [String] = []) {
        self.categories = categories
    }
    
    func total(for category: String, in period: RecordPeriod) -> Double {
        guard let databaseManager = DB.shared.manager, let tallies = databaseManager.totals(for: period), let tally = tallies[category] else { return 0 }
        
        return tally
    }
    
    func total(ofReconciled isReconciled: Bool, in period: RecordPeriod) -> Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.total(ofReconciled: isReconciled, for: period)
    }
    
    func startingBalance(asOf period: RecordPeriod) -> Double {
        guard let databaseManager = DB.shared.manager, let records = try? databaseManager.records(inRange: period), let firstRecord = records.first, let startBalance = try? databaseManager.balance(for: firstRecord) else { return 0 }
        
        return startBalance
    }
    
    func balance(asOf period: RecordPeriod) -> Double {
        guard let databaseManager = DB.shared.manager, let records = try? databaseManager.records(inRange: period), let lastRecord = records.last, let balance = try? databaseManager.balance(for: lastRecord) else { return 0 }
        
        return balance
    }
}
