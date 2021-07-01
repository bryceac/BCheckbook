//
//  GetRecords.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

class Records: ObservableObject {
    @Published var items: [Record] {
        didSet {
            if items.count > 1 {
                items.sort()
            }
            
            items.forEach { record in
                record.previousRecord = items.element(before: record)
            }
        }
    }
    
    init(withRecords records: [Record] = []) {
        items = records
        
        guard !records.isEmpty && records.count > 1 else { return }
        
        for index in records.indices where index != records.startIndex {
            let PREVIOUS_INDEX = records.index(before: index)
            
            records[index].previousRecord = records[PREVIOUS_INDEX]
        }
    }
}
