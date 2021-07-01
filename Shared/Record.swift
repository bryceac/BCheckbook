//
//  Record.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

class Record: Identifiable, ObservableObject, Codable {
    let id: String
    @Published var event: Event
    var previousRecord: Record? = nil
    
    var balance: Double {
        var value = previousRecord?.balance ?? 0
        
        switch event.type {
        case .deposit: value += event.amount
        case .withdrawal: value -= event.amount
        }
        
        return value
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, event = "transaction"
    }
    
    init(withID id: String = UUID().uuidString, transaction: Event = Event(), previousRecord: Record? = nil) {
        (self.id, self.event, self.previousRecord) = (id, transaction, previousRecord)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let CONTAINER = try decoder.container(keyedBy: CodingKeys.self)
        
        let ID = CONTAINER.contains(.id) ? try CONTAINER.decode(String.self, forKey: .id) : UUID().uuidString
        
        let TRANSACTION = try CONTAINER.decode(Event.self, forKey: .event)
        
        self.init(withID: ID, transaction: TRANSACTION)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(event, forKey: .event)
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
        return lhs.id < rhs.id || lhs.event < rhs.event
    }
}

extension Record: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(event)
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
    
    func element(before record: Record) -> Record? {
        guard self.first! != record else { return nil }
        guard let INDEX = self.firstIndex(of: record) else { return nil }
        
        let PREVIOUS_INDEX = self.index(before: INDEX)
        
        return self[PREVIOUS_INDEX]
    }
    
    func element(after record: Record) -> Record? {
        guard self.last! != record else { return nil }
        guard let INDEX = self.firstIndex(of: record) else { return nil }
        
        let NEXT_INDEX = self.index(after: INDEX)
        
        return self[NEXT_INDEX]
    }
}
