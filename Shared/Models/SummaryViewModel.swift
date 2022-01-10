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
    
    var startingBalance: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let firstRecord = storedRecords.first, let balance = try? databaseManager.balance(for: firstRecord) else { return 0 }
        
        return balance
    }
    
    var startingBalanceForWeek: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let firstRecord = storedRecords.week.first, let balance = try? databaseManager.balance(for: firstRecord) else { return 0 }
        
        return balance
    }
    
    var startingBalanceForMonth: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let firstRecord = storedRecords.month.first, let balance = try? databaseManager.balance(for: firstRecord) else { return 0 }
        
        return balance
    }
    
    var startingBalanceForQuarter: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let firstRecord = storedRecords.quarter.first, let balance = try? databaseManager.balance(for: firstRecord) else { return 0 }
        
        return balance
    }
    
    var startingBalanceForSixMonths: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let firstRecord = storedRecords.sixMonths.first, let balance = try? databaseManager.balance(for: firstRecord) else { return 0 }
        
        return balance
    }
    
    var startingBalanceForYear: Double {
        guard let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records, let firstRecord = storedRecords.year.first, let balance = try? databaseManager.balance(for: firstRecord) else { return 0 }
        
        return balance
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
    
    var totalReconciledForWeek: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.reconciledTotalForWeek
    }
    
    var totalReconciledForMonth: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.reconciledTotalForMonth
    }
    
    var totalReconciledForQuarter: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.reconciledTotalForQuarter
    }
    
    var totalReconciledForSixMonths: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.reconciledTotalForSixMonths
    }
    
    var totalReconciledForYear: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.reconciledTotalForYear
    }
    
    var totalUnreconciled: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.unreconciledTotal
    }
    
    var totalUnreconciledForWeek: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.unreconciledTotalForWeek
    }
    
    var totalUnreconciledForMonth: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.unreconciledTotalForMonth
    }
    
    var totalUnreconciledForQuarter: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.unreconciledTotalForQuarter
    }
    
    var totalUnreconciledForSixMonths: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.unreconciledTotalForSixMonths
    }
    
    var totalUnreconciledForYear: Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        return databaseManager.unreconciledTotalForYear
    }
    
    init(withCategories categories: [String] = []) {
        self.categories = categories
    }
    
    func total(for category: String, in period: RecordPeriod) -> Double {
        guard let databaseManager = DB.shared.manager else { return 0 }
        
        var tally: Double = 0
        
        switch period {
        case .all:
            if let tallies = databaseManager.totals, let value = tallies[category] {
                tally = value
            }
        case .week:
            if let tallies = databaseManager.totalsForWeek, let value = tallies[category] {
                tally = value
            }
        case .month:
            if let tallies = databaseManager.totalsForMonth, let value = tallies[category] {
                tally = value
            }
        case .threeMonths:
            if let tallies = databaseManager.totalsForQuarter, let value = tallies[category] {
                tally = value
            }
        case .sixMonths:
            if let tallies = databaseManager.totalsForSixMonths, let value = tallies[category] {
                tally = value
            }
        case .year:
            if let tallies = databaseManager.TotalsForYear, let value = tallies[category] {
                tally = value
            }
        }
        
        return tally
    }
}
