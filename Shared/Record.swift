//
//  Record.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

class Record: Identifiable, ObservableObject, Codable {
    let id: String
    @Published var transaction: Event {
        didSet {
            switch transaction.type {
            case .deposit: balance += transaction.amount
            case .withdrawal: balance -= transaction.amount
            }
        }
    }
    
    @Published var balance: Double = 0
    
    private enum CodingKeys: String, CodingKey {
        case id, transaction
    }
    
    init(withID id: String = UUID().uuidString, transaction: Event = Event()) {
        (self.id, self.transaction) = (id, transaction)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let CONTAINER = try decoder.container(keyedBy: CodingKeys.self)
        
        let ID = CONTAINER.contains(.id) ? try CONTAINER.decode(String.self, forKey: .id) : UUID().uuidString
        
        let TRANSACTION = try CONTAINER.decode(Event.self, forKey: .transaction)
        
        self.init(withID: ID, transaction: TRANSACTION)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(transaction, forKey: .transaction)
    }
    
    class func load(from path: URL) throws -> [Record] {
        let JSON_DECODER = JSONDecoder()
        
        let RECORD_DATA = try Data(contentsOf: path)
        let DECODED_RECORDS = try JSON_DECODER.decode([Record].self, from: RECORD_DATA)
        
        return DECODED_RECORDS
    }
}

extension Record: Comparable {
    static func ==(lhs: Record, rhs: Record) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Record, rhs: Record) -> Bool {
        return lhs.id < rhs.id || lhs.transaction < rhs.transaction
    }
}

extension Record: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(transaction)
    }
}

extension Array where Element == Record {
    func save(to path: URL) throws {
        let JSON_ENCODER = JSONEncoder()
        JSON_ENCODER.outputFormatting = .prettyPrinted
        
        let ENCODED_RECORDS = try JSON_ENCODER.encode(self)
        
        #if os(iOS)
        try ENCODED_RECORDS.write(to: path, options: .noFileProtection)
        #else
        try ENCODED_RECORDS.write(to: path, options: .atomic)
        #endif
    }
    
    func element(before item: Element) -> Element? {
        guard let INDEX = self.firstIndex(of: item) else { return nil }
        guard INDEX > self.startIndex else { return nil }
        
        let PREVIOUS_INDEX = self.index(before: INDEX)
        
        return self[PREVIOUS_INDEX]
    }
}
