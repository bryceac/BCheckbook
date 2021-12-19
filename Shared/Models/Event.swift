//
//  Event.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

struct Event {
    var date: Date = Date()
    var checkNumber: Int? = nil
    var category: String? = nil
    var vendor: String = ""
    var memo: String = ""
    var amount: Double = 0
    var type: EventType = .withdrawal
    var isReconciled: Bool = false
    
    
    static let DF: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let CURRENCY_FORMAT: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
}

extension Event {
    /**
        Initialize Event without explicitly setting setting event type..
        - Parameters:
            - parameter date: The date the transaction took place
            - parameter checkNumber: The check number of the transaction
            - parameter category: category for transaction.
            - parameter vendor: The vendor
            - parameter memo: description of the transaction
            - parameter amount: The amount of cash exchanged. A negative value make it a withdrawal.
            - parameter isReconciled: Whether the transaction cleared or not.
        - Returns: Event Object
     */
    init(date: Date = Date(), checkNumber: Int? = nil,
         category: String? = nil, vendor: String = "", memo: String = "", amount: Double = 0, andIsReconciled isReconciled: Bool = false) {
        self.date = date
        self.checkNumber = checkNumber
        self.category = category
        self.vendor = vendor
        self.memo = memo
        self.amount = abs(amount)
        self.type = amount <= 0 ? EventType.withdrawal : EventType.deposit
        self.isReconciled = isReconciled
    }
    
    /**
     Initialize Event with a date String. This is more of a convenience initializer.
     - Parameters:
            - parameter date: The date the transaction took place.
            - parameter checkNumber: The check Number of the transaction
            - parameter category: category for transaction
            - parameter vendor: The vendor
            - parameter memo: description of transaction
            - parameter amount: The amount exchanged. A negative value is automatically labelled a withdrawal.
            - parameter isReconciled: Whether the transaction cleared or not.
     - Returns: Optional Event. Value will be nil if the the date is not in YYYY-MM-DD format.
     */
    init?(date: String, checkNumber: Int? = nil,
         category: String? = nil, vendor: String = "", memo: String = "", amount: Double = 0, andIsReconciled isReconciled: Bool = false) {
        guard let date = Event.DF.date(from: date) else { return nil }
        
        self.init(date: date, checkNumber: checkNumber, category: category, vendor: vendor, memo: memo, amount: amount, andIsReconciled: isReconciled)
    }
}

extension Event: Codable {
    private enum CodingKeys: String, CodingKey {
        case date, checkNumber = "check_number", category, vendor, memo, amount, type, isReconciled = "is_reconciled"
    }
    
    init(from decoder: Decoder) throws {
        let CONTAINER = try decoder.container(keyedBy: CodingKeys.self)
        
        if CONTAINER.contains(.date) {
            let DATE_STRING = try CONTAINER.decode(String.self, forKey: .date)
            if let TRANSACTION_DATE = Event.DF.date(from: DATE_STRING) {
                date = TRANSACTION_DATE
            }
        }
        
        if CONTAINER.contains(.checkNumber) {
            checkNumber = try CONTAINER.decode(Int.self, forKey: .checkNumber)
        }
        
        if CONTAINER.contains(.category) {
            category = try CONTAINER.decode(String.self, forKey: .category)
        }
        
        vendor = try CONTAINER.decode(String.self, forKey: .vendor)
        
        if CONTAINER.contains(.memo) {
            memo = try CONTAINER.decode(String.self, forKey: .memo)
        }
        
        amount = try CONTAINER.decode(Double.self, forKey: .amount)
        
        type = try CONTAINER.decode(EventType.self, forKey: .type)
        
        if CONTAINER.contains(.isReconciled) {
            isReconciled = try CONTAINER.decode(Bool.self, forKey: .isReconciled)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(Event.DF.string(from: date), forKey: .date)
        
        if let checkNumber = checkNumber {
            try container.encode(checkNumber, forKey: .checkNumber)
        }
        
        try container.encode(vendor, forKey: .vendor)
        
        if let category = category {
            try container.encode(category, forKey: .category)
        }
        
        if !memo.isEmpty {
            try container.encode(memo, forKey: .memo)
        }
        
        try container.encode(amount, forKey: .amount)
        
        try container.encode(type, forKey: .type)
        
        if isReconciled {
            try container.encode(isReconciled, forKey: .isReconciled)
        }
    }
}

extension Event: Comparable {
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.date == rhs.date && lhs.checkNumber == rhs.checkNumber && lhs.vendor == rhs.vendor && lhs.memo == rhs.memo && lhs.amount == rhs.amount && lhs.type == rhs.type && lhs.isReconciled == rhs.isReconciled
    }
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        var isLessThanOther = false
        
        if let firstNumber = lhs.checkNumber, let secondNumber = rhs.checkNumber {
            isLessThanOther = lhs.date < rhs.date || firstNumber < secondNumber || lhs.vendor < rhs.vendor || lhs.amount < rhs.amount
        } else {
            isLessThanOther = lhs.date < rhs.date || lhs.vendor < rhs.vendor || lhs.amount < rhs.amount
        }
        
        return isLessThanOther
    }
}

extension Event: Hashable {}
