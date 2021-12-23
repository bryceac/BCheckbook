//
//  GetRecords.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation
import Combine

class Records: ObservableObject {
    @Published var items: [Record] {
        didSet {
            cancellables = []
            sortedRecords.forEach { record in
                let cancellable = record.objectWillChange.sink { _ in
                    self.objectWillChange.send()
                }
                
                cancellables.append(cancellable)
            }
        }
    }
    
    var cancellables: [AnyCancellable] = []
    
    var sortedRecords: [Record] {
        
        let sortedArray = items.sorted { firstRecord, secondRecord in
            firstRecord.event.date < secondRecord.event.date
        }
        
        DispatchQueue.main.async {
            if let databaseManager = DB.shared.manager, let storedRecords = databaseManager.records {
                self.items.forEach { item in
                    item.previousRecord = storedRecords.element(before: item)
                }
            } else {
                self.items.forEach { item in
                    item.previousRecord = sortedArray.element(before: item)
                }
            }
        }
        
        return sortedArray
    }
    
    init(withRecords records: [Record] = []) {
        items = records
    }
    
    func add(_ record: Record) {
        items.append(record)
    }
    
    func remove(at index: Int) {
        items.remove(at: index)
    }
    
    func remove(_ record: Record) {
        guard let RECORD_INDEX = self.items.firstIndex(of: record) else { return }
        
        self.remove(at: RECORD_INDEX)
    }
    
    func clear() {
        items.removeAll()
    }
    
    func element(matching record: Record) -> Record? {
        guard items.contains(record) else { return nil }
        
        return items.first(where: { $0 == record })
    }
}
