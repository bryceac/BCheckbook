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
    
    func balance(asOf period: RecordPeriod) -> Double {
        guard let databaseManager = DB.shared.manager, let records = databaseManager.records else { return 0 }
        
        var value: Double = 0
        
        switch period {
        case .all:
            if let lastRecord = records.last, let balance = try? databaseManager.balance(for: lastRecord) {
                value = balance
            }
        case .week:
            if let lastRecord = records.week.last, let balance = try? databaseManager.balance(for: lastRecord) {
                value = balance
            }
        case .month:
            if let lastRecord = records.month.last, let balance = try? databaseManager.balance(for: lastRecord) {
                value = balance
            }
        case .threeMonths:
            if let lastRecord = records.quarter.last, let balance = try? databaseManager.balance(for: lastRecord) {
                value = balance
            }
        case .sixMonths:
            if let lastRecord = records.sixMonths.last, let balance = try? databaseManager.balance(for: lastRecord) {
                value = balance
            }
        case .year:
            if let lastRecord = records.year.last, let balance = try? databaseManager.balance(for: lastRecord) {
                value = balance
            }
        }
        
        return value
    }
}
