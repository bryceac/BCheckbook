//
//  RecordArray+data.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/8/21.
//

import Foundation

extension Array where Element == Record {
    var data: Data? {
        let JSON_ENCODER = JSONEncoder()
        JSON_ENCODER.outputFormatting = .prettyPrinted
        
        guard let ENCODED_RECORDS = try? JSON_ENCODER.encode(self) else { return nil }
        
        return ENCODED_RECORDS
    }
}
