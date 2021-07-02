//
//  EvenType.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

enum EventType: String, CaseIterable {
    case deposit, withdrawal
}

extension EventType: Codable {
    init(from decoder: Decoder) throws {
        let CONTAINER = try decoder.singleValueContainer()
        
        let TYPE_STRING = try CONTAINER.decode(String.self)
        
        guard let TYPE = EventType.allCases.first(where: { $0.rawValue.caseInsensitiveCompare(TYPE_STRING) == .orderedSame }) else {
            throw EventTypeError.invalidType
        }
        
        self = TYPE
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(self.rawValue)
    }
}
