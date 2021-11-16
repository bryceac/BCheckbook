//
//  Records+removeRecord.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/10/21.
//

import Foundation

extension Records {
    func remove(_ record: Record) {
        guard let RECORD_INDEX = self.items.firstIndex(of: record) else { return }
        
        self.remove(at: RECORD_INDEX)
    }
}