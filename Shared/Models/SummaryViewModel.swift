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
        guard let databaseManager = DB.shared.manager, let records = databaseManager.records else { return 0 }
        
        var value: Double = 0
        
        switch period {
        case .all:
            if let firstRecord = records.first, let balance = try? databaseManager.balance(for: firstRecord) {
                value = balance
            }
        case .week:
            if let firstRecord = records.week.first, let balance = try? databaseManager.balance(for: firstRecord) {
                value = balance
            }
        case .month:
            if let firstRecord = records.month.first, let balance = try? databaseManager.balance(for: firstRecord) {
                value = balance
            }
        case .threeMonths:
            if let firstRecord = records.quarter.first, let balance = try? databaseManager.balance(for: firstRecord) {
                value = balance
            }
        case .sixMonths:
            if let firstRecord = records.sixMonths.first, let balance = try? databaseManager.balance(for: firstRecord) {
                value = balance
            }
        case .year:
            if let firstRecord = records.year.first, let balance = try? databaseManager.balance(for: firstRecord) {
                value = balance
            }
        }
        
        return value
    }
}
