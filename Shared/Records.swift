//
//  GetRecords.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

class Records: ObservableObject {
    @Published private var items: [Record] {
        didSet {
            items.sorted().forEach { record in
                record.previousRecord = items.element(before: record)
            }
        }
    }
    
    var sortedRecords: [Record] {
        return items.sorted()
    }
    
    init(withRecords records: [Record] = []) {
        items = records
        
        guard !records.isEmpty && records.count > 1 else { return }
        
        for index in records.indices where index != records.startIndex {
            let PREVIOUS_INDEX = records.index(before: index)
            
            records[index].previousRecord = records[PREVIOUS_INDEX]
        }
    }
    
    func add(_ record: Record) {
        items.append(record)
    }
    
    func remove(at index: Int) {
        items.remove(at: index)
    }
}
