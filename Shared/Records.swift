//
//  GetRecords.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

class Records: ObservableObject {
    @Published var items: [Record]
    
    init(withRecords records: [Record] = []) {
        items = records
        
        guard !records.isEmpty && records.count > 1 else { return }
        
        for index in records.indices where index != records.startIndex {
            let PREVIOUS_INDEX = records.index(before: index)
            
            records[index].previousRecord = records[PREVIOUS_INDEX]
        }
    }
    
    func add(_ record: Record) {
        if let PREVIOUS_RECORD = items.last {
            items.append(record)
            
            let NEWEST_INDEX = items.indices.last!
            
            items[NEWEST_INDEX].previousRecord = PREVIOUS_RECORD
        } else {
            items.append(record)
        }
    }
    
    func remove(at index: Int) {
        guard index < items.endIndex else { return }
        
        let NEXT_INDEX = items.index(after: index)
        
        if index < items.indices.last! && index > items.startIndex {
            
            let PREVIOUS_INDEX = items.index(before: index)
            
            items[NEXT_INDEX].previousRecord = items[PREVIOUS_INDEX]
        } else if index == items.startIndex && items.count > 1 {
            items[NEXT_INDEX].previousRecord = nil
        } else {
            items.remove(at: index)
        }
    }
}
