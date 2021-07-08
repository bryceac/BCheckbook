//
//  Record+loadfromData.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/8/21.
//

import Foundation

extension Record {
    class func load(from data: Data) throws -> [Record] {
        let JSON_DECODER = JSONDecoder()
        
        let SAVED_RECORDS = try JSON_DECODER.decode([Record].self, from: data)
        
        return SAVED_RECORDS
    }
}
