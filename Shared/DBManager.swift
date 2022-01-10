//
//  File.swift
//  
//
//  Created by Bryce Campbell on 12/16/21.
//

import Foundation
import SQLite

class DBManager {
    
    /// records in database
    var records: [Record]? {
        try? retrieveRecords()
    }
    
    /// categories in database
    var categories: [String]? {
        try? retrieveCategories()
    }
    
    var unreconciledTotal: Double {
        guard let total = try? retrieveTotal(ofReconciled: false, in: .all) else { return 0 }
        
        return total
    }
    
    var unreconciledTotalForWeek: Double {
        guard let total = try? retrieveTotal(ofReconciled: false, in: .week) else { return 0 }
        
        return total
    }
    
    var unreconciledTotalForMonth: Double {
        guard let total = try? retrieveTotal(ofReconciled: false, in: .month) else { return 0 }
        
        return total
    }
    
    var unreconciledTotalForQuarter: Double {
        guard let total = try? retrieveTotal(ofReconciled: false, in: .threeMonths) else { return 0 }
        
        return total
    }
    
    var unreconciledTotalForSixMonths: Double {
        guard let total = try? retrieveTotal(ofReconciled: false, in: .sixMonths) else { return 0 }
        
        return total
    }
    
    var unreconciledTotalForYear: Double {
        guard let total = try? retrieveTotal(ofReconciled: false, in: .year) else { return 0 }
        
        return total
    }
    
    var reconciledTotal: Double {
        guard let total = try? retrieveTotal(ofReconciled: true, in: .all) else { return 0 }
        
        return total
    }
    
    var reconciledTotalForWeek: Double {
        guard let total = try? retrieveTotal(ofReconciled: true, in: .week) else { return 0 }
        
        return total
    }
    
    var reconciledTotalForMonth: Double {
        guard let total = try? retrieveTotal(ofReconciled: true, in: .month) else { return 0 }
        
        return total
    }
    
    var reconciledTotalForQuarter: Double {
        guard let total = try? retrieveTotal(ofReconciled: true, in: .threeMonths) else { return 0 }
        
        return total
    }
    
    var reconciledTotalForSixMonths: Double {
        guard let total = try? retrieveTotal(ofReconciled: true, in: .sixMonths) else { return 0 }
        
        return total
    }
    
    var reconciledTotalForYear: Double {
        guard let total = try? retrieveTotal(ofReconciled: true, in: .year) else { return 0 }
        
        return total
    }
    
    private var db: Connection
    
    // Tables
    private let LEDGER_VIEW = Table("ledger")
    private let CATEGORY_TABLE = Table("categories")
    private let TRABSACTION_TABLE = Table("trades")
    
    
    /* The following are field properties needed for tables.
     While many CAN be shared, due to the tables sharing fields with similiar names, there are properties referring to the same column name that will grab other data types, which is necessary for inserting and updating data.
     */
    
    // ledger fields
    private let ID_FIELD = Expression<String>("id")
    private let DATE_FIELD = Expression<String>("date")
    private let CHECK_NUMBER_FIELD = Expression<Int?>("check_number")
    private let RECONCILED_FIELD = Expression<String>("reconciled")
    private let VENDOR_FIELD = Expression<String>("vendor")
    private let MEMO_FIELD = Expression<String>("memo")
    private let AMOUNT_FIELD = Expression<Double>("amount")
    private let CATEGORY_FIELD = Expression<String?>("category")
    private let BALANCE_FIELD = Expression<Double>("balance")
    
    
    // Transaction Fields
    private let TRANSACTION_CATEGORY_ID_FIELD = Expression<Int?>("category")
    private let TRANSACTION_RECONCILED_FIELD = Expression<Int>("reconciled")
    
    // Category Fields
    private let CATEGORY_ID_FIELD = Expression<Int>("id")
    
    
    /**
     default initializer that loads data from a Database.
    - parameter db: The location of the database.
    - Throws: Result.Error if connection could not be established and any errors thrown by functions called.
    - Returns: Checkbook object.
     */
    init(withDB db: URL) throws {
        self.db = try Connection(db.absoluteString)
    }
    
    /**
     retrieve balance for a particular record.
     - parameter record: The record to look for.
     */
    func balance(for record: Record) throws -> Double {
        let row = try db.pluck(LEDGER_VIEW.filter(ID_FIELD == record.id))
        
        var balance: Double = 0
        
        if let result = row {
            balance = result[BALANCE_FIELD]
        }
        
        return balance
    }
    
    /**
     add specified record to database.
     - parameter record: The record to add to database.
     */
    func add(record: Record) throws {
        guard try !databaseHas(record: record) else { return }
        
        var insert: Insert!
        
        if let category = record.event.category {
            if let categoryID = try? id(ofCategory: category) {
                insert = TRABSACTION_TABLE.insert(ID_FIELD <- record.id, DATE_FIELD <- Event.DF.string(from: record.event.date), CHECK_NUMBER_FIELD <- record.event.checkNumber, VENDOR_FIELD <- record.event.vendor, MEMO_FIELD <- record.event.memo, TRANSACTION_CATEGORY_ID_FIELD <- categoryID, AMOUNT_FIELD <- EventType.withdrawal ~= record.event.type ? record.event.amount * -1.0 : record.event.amount, TRANSACTION_RECONCILED_FIELD <- record.event.isReconciled ? 1 : 0)
            } else {
                try add(category: category)
                
                guard let categoryID = try? id(ofCategory: category) else { return }
            
                insert = TRABSACTION_TABLE.insert(ID_FIELD <- record.id, DATE_FIELD <- Event.DF.string(from: record.event.date), CHECK_NUMBER_FIELD <- record.event.checkNumber, VENDOR_FIELD <- record.event.vendor, MEMO_FIELD <- record.event.memo, TRANSACTION_CATEGORY_ID_FIELD <- categoryID, AMOUNT_FIELD <- EventType.withdrawal ~= record.event.type ? record.event.amount * -1.0 : record.event.amount, TRANSACTION_RECONCILED_FIELD <- record.event.isReconciled ? 1 : 0)
            }
        } else {
            insert = TRABSACTION_TABLE.insert(ID_FIELD <- record.id, DATE_FIELD <- Event.DF.string(from: record.event.date), CHECK_NUMBER_FIELD <- record.event.checkNumber, VENDOR_FIELD <- record.event.vendor, MEMO_FIELD <- record.event.memo, AMOUNT_FIELD <- EventType.withdrawal ~= record.event.type ? record.event.amount * -1.0 : record.event.amount, TRANSACTION_RECONCILED_FIELD <- record.event.isReconciled ? 1 : 0)
        }
        
        try db.run(insert)
    }
    
    /**
     add specified category to database.
     - parameter category: The category to be added to the database.
     */
    func add(category: String) throws  {
        guard case .none = try id(ofCategory: category) else { return }
        try db.run(CATEGORY_TABLE.insert(CATEGORY_FIELD <- category))
    }
    
    private func id(ofCategory category: String?) throws -> Int? {
        guard let category = category else { return nil }
        
        let row = try db.pluck(CATEGORY_TABLE.filter(CATEGORY_FIELD == category))
            
        guard let categoryRow = row else { return nil }
        
        return categoryRow[CATEGORY_ID_FIELD]
    }
    
    /**
     add multiple records to database. This function is useful for importing data.
     - parameter records: the records to add.
     */
    func add(records: [Record]) throws {
        for record in records {
            try add(record: record)
        }
    }
    
    /**
     add multiple categories to database.
     - parameter categories: the categories to add.
     */
    func add(categories: [String]) throws {
        for category in categories {
            try add(category: category)
        }
    }
    
    private func databaseHas(record: Record) throws -> Bool {
        let TRANSACTION_RECORD = LEDGER_VIEW.filter(ID_FIELD == record.id)
        
        guard let _ = try db.pluck(TRANSACTION_RECORD) else { return false }
        
        return true
    }
    
    private func retrieveRecords() throws -> [Record] {
        var records: [Record] = []
        for row in try db.prepare(LEDGER_VIEW) {
            guard let transaction = Event(date: row[DATE_FIELD], checkNumber: row[CHECK_NUMBER_FIELD], category: row[CATEGORY_FIELD], vendor: row[VENDOR_FIELD], memo: row[MEMO_FIELD], amount: row[AMOUNT_FIELD], andIsReconciled: row[RECONCILED_FIELD] == "Y") else { continue }
            
            let record = Record(withID: row[ID_FIELD], transaction: transaction)
            
            records.append(record)
        }
        
        return records
    }
    
    private func retrieveCategories() throws -> [String] {
        var categories: [String] = []
        
        for row in try db.prepare(CATEGORY_TABLE) {
            guard let category = row[CATEGORY_FIELD] else { continue }
            
            categories.append(category)
        }
        
        return categories
    }
    
    private func ledger(withRange range: RecordPeriod = .all) -> Table {
        var table: Table!
        
        switch range {
        case .all:
            table = LEDGER_VIEW
        case .week:
            let now = Date()
            if let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) {
                table = LEDGER_VIEW.filter(Event.DF.string(from: oneWeekAgo)...Event.DF.string(from: now) ~= DATE_FIELD)
            }
        case .month:
            let now = Date()
            if let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -7, to: now) {
                table = LEDGER_VIEW.filter(Event.DF.string(from: oneMonthAgo)...Event.DF.string(from: now) ~= DATE_FIELD)
            }
        case .threeMonths:
            let now = Date()
            if let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: now) {
                table = LEDGER_VIEW.filter(Event.DF.string(from: threeMonthsAgo)...Event.DF.string(from: now) ~= DATE_FIELD)
            }
        case .sixMonths:
            let now = Date()
            if let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: now) {
                table = LEDGER_VIEW.filter(Event.DF.string(from: sixMonthsAgo)...Event.DF.string(from: now) ~= DATE_FIELD)
            }
        case .year:
            let now = Date()
            if let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) {
                table = LEDGER_VIEW.filter(Event.DF.string(from: oneYearAgo)...Event.DF.string(from: now) ~= DATE_FIELD)
            }
        }
        
        return table
    }
    
    private func retrieveTotals(for period: RecordPeriod) throws -> [String: Double] {
        
        let groupQuery = ledger(withRange: period).select(CATEGORY_FIELD, AMOUNT_FIELD.sum)
        
        return try db.prepare(groupQuery).reduce(into: [:], { tallies, row in
            let category = row[CATEGORY_FIELD] ?? "Uncategorized"
            let tally = row[AMOUNT_FIELD.sum] ?? 0
            
            tallies[category] = tally
        })
    }
    
    private func totalsQuery(for isReconciled: Bool, in period: RecordPeriod) -> String {
        var statement = ""
        
        switch period {
        case .all:
            statement = "SELECT SUM(amount) FROM ledger WHERE reconciled = \"\(isReconciled ? "Y" : "N")\""
        case .week:
            statement = "SELECT SUM(amount) FROM ledger WHERE reconciled = \"\(isReconciled ? "Y" : "N")\" AND \"date\" BETWEEN date('now', '-1 weeks') AND date('now')"
        case .month:
            statement = "SELECT SUM(amount) FROM ledger WHERE reconciled = \"\(isReconciled ? "Y" : "N")\" AND \"date\" BETWEEN date('now', '-1 months') AND date('now')"
        case .threeMonths:
            statement = "SELECT SUM(amount) FROM ledger WHERE reconciled = \"\(isReconciled ? "Y" : "N")\" AND \"date\" BETWEEN date('now', '-3 months') AND date('now')"
        case .sixMonths:
            statement = "SELECT SUM(amount) FROM ledger WHERE reconciled = \"\(isReconciled ? "Y" : "N")\" AND \"date\" BETWEEN date('now', '-6 months') AND date('now')"
        case .year:
            statement = "SELECT SUM(amount) FROM ledger WHERE reconciled = \"\(isReconciled ? "Y" : "N")\" AND \"date\" BETWEEN date('now', '-1 years') AND date('now')"
        }
        
        return statement
    }
    
    private func retrieveTotal(ofReconciled reconciled: Bool, in period: RecordPeriod) throws -> Double {
        let totalQuery = totalsQuery(for: reconciled, in: period)
        
        var value: Double = 0
        
        for row in try db.prepare(totalQuery) {
            guard let retrievedValue = row[0] as? Double else { continue }
            value = retrievedValue
        }
        
        return value
    }
    
    func totals(for period: RecordPeriod) -> [String: Double]? {
        guard let retrievedTotals = try? retrieveTotals(for: period) else { return nil }
        
        return retrievedTotals
    }
    
    /**
     update specified record in database.
     - parameter record: The record to be updated.
     */
    func update(record: Record) throws {
        guard try databaseHas(record: record) else { return }
        
        let TRSNSACTION_RECORD = TRABSACTION_TABLE.filter(ID_FIELD == record.id)
        
        var update: Update!
        
        if let category = record.event.category {
            if let categoryID = try id(ofCategory: category) {
                update = TRSNSACTION_RECORD.update(DATE_FIELD <- Event.DF.string(from: record.event.date), CHECK_NUMBER_FIELD <- record.event.checkNumber, TRANSACTION_CATEGORY_ID_FIELD <- categoryID, VENDOR_FIELD <- record.event.vendor, MEMO_FIELD <- record.event.memo, AMOUNT_FIELD <- EventType.withdrawal ~= record.event.type ? record.event.amount * -1.0 : record.event.amount, TRANSACTION_RECONCILED_FIELD <- record.event.isReconciled ? 1 : 0 )
            } else {
                try add(category: category)
                
                guard let categoryID = try id(ofCategory: category) else { return }
                
                update = TRSNSACTION_RECORD.update(DATE_FIELD <- Event.DF.string(from: record.event.date), CHECK_NUMBER_FIELD <- record.event.checkNumber, TRANSACTION_CATEGORY_ID_FIELD <- categoryID, VENDOR_FIELD <- record.event.vendor, MEMO_FIELD <- record.event.memo, AMOUNT_FIELD <- EventType.withdrawal ~= record.event.type ? record.event.amount * -1.0 : record.event.amount, TRANSACTION_RECONCILED_FIELD <- record.event.isReconciled ? 1 : 0 )
            }
            
        } else {
            update = TRSNSACTION_RECORD.update(DATE_FIELD <- Event.DF.string(from: record.event.date), CHECK_NUMBER_FIELD <- record.event.checkNumber, TRANSACTION_CATEGORY_ID_FIELD <- try id(ofCategory: record.event.category), VENDOR_FIELD <- record.event.vendor, MEMO_FIELD <- record.event.memo, AMOUNT_FIELD <- EventType.withdrawal ~= record.event.type ? record.event.amount * -1.0 : record.event.amount, TRANSACTION_RECONCILED_FIELD <- record.event.isReconciled ? 1 : 0 )
        }

        try db.run(update)
    }
    
    /**
     remove specified record from database.
     - parameter record: The record to remove
     */
    func remove(record: Record) throws {
        guard try databaseHas(record: record) else { return }
        let TRSNSACTION_RECORD = TRABSACTION_TABLE.filter(ID_FIELD == record.id)
        
        try db.run(TRSNSACTION_RECORD.delete())
    }
    
    /**
     remove specified category from data base.
     - parameter category: The category to remove.
     */
    func remove(category: String) throws {
        guard let id = try id(ofCategory: category) else { return }
        let CATEGORY_RECORD = CATEGORY_TABLE.filter(CATEGORY_ID_FIELD == id)
        
        try db.run(CATEGORY_RECORD.delete())
    }
    
    /**
     remove a specified list of records.
     - parameter records: the records to remove
     */
    func remove(records: [Record]) throws {
        for record in records {
            try remove(record: record)
        }
    }
    
    /**
     remove a specified list of categories.
     - parameter categories: list of categories to remoe.
     */
    func remove(categories: [String]) throws {
        for category in categories {
            try remove(category: category)
        }
    }
}
