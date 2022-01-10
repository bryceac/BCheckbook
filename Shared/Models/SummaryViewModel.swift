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
    
    var grandTotal: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let lastRecord = storedRecords.last, let balance = try? databaseManager.balance(for: lastRecord) else { return 0 }
        
        return balance
    }
    
    var totalForWeek: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let lastRecord = storedRecords.week.last, let balance = try? databaseManager.balance(for: lastRecord) else { return 0 }
        
        return balance
    }
    
    var totalForMonth: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let lastRecord = storedRecords.month.last, let balance = try? databaseManager.balance(for: lastRecord) else { return 0 }
        
        return balance
    }
    
    var totalForQuarter: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let lastRecord = storedRecords.quarter.last, let balance = try? databaseManager.balance(for: lastRecord) else { return 0 }
        
        return balance
    }
    
    var totalForSixMonths: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let lastRecord = storedRecords.sixMonths.last, let balance = try? databaseManager.balance(for: lastRecord) else { return 0 }
        
        return balance
    }
    
    var totalForYear: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let lastRecord = storedRecords.year.last, let balance = try? databaseManager.balance(for: lastRecord) else { return 0 }
        
        return balance
    }
    
    var totalReconciled: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.reconciledTotal
    }
    
    var totalUnreconciled: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.unreconciledTotal
    }
    
    init(withCategories categories: [String] = []) {
        self.categories = categories
    }
    
    func total(for category: String) -> Double {
        guard let databaseManager = DB.shared.manager, let tallies = databaseManager.totals, let tally = tallies[category] else { return 0 }
        
        return tally
    }
}
