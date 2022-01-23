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
        return items.sorted { firstRecord, secondRecord in
            firstRecord.event.date < secondRecord.event.date
        }
    }
    
    var balances: [Record: Double] {
        return sortedRecords.reduce(into: [Record: Double]()) { balances, record in
            guard let databaseManager = DB.shared.manager else { return }
            balances[record] = try? databaseManager.balance(for: record)
        }
    }
    
    init(withRecords records: [Record] = []) {
        items = records
    }
    
    func add(_ record: Record) {
        items.append(record)
    }
    
    func add(_ records: [Record]) {
        items += records
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
    
    func filter(vendor: String? = nil, category: String? = nil) -> [Record] {
        var filteredRecords: [Record] = sortedRecords
        
        switch (vendor, category) {
        case let (.some(vendor), .some(category)):
            filteredRecords = filteredRecords.filter { record in
                if category.caseInsensitiveCompare("Uncategorized") == .orderedSame {
                    return (record.event.vendor.lowercased().contains(vendor) || record.event.vendor.caseInsensitiveCompare(vendor) == .orderedSame) &&
                        .none ~= record.event.category
                } else {
                    guard let recordCategory = record.event.category else { return false }
                    
                    return (record.event.vendor.lowercased().contains(vendor) || record.event.vendor.caseInsensitiveCompare(vendor) == .orderedSame) &&
                    (recordCategory.lowercased().contains(category.lowercased()) || recordCategory.caseInsensitiveCompare(category) == .orderedSame)
                }
                
            }
        case let (.some(vendor), .none):
            filteredRecords = filteredRecords.filter { $0.event.vendor.caseInsensitiveCompare(vendor) == .orderedSame }
        case let (.none, .some(category)):
            filteredRecords = filteredRecords.filter {
                
                if category.caseInsensitiveCompare("Uncategorized") == .orderedSame {
                    return .none ~= $0.event.category
                } else {
                    guard let recordCategory = $0.event.category else { return false }
                    
                    return recordCategory.lowercased().contains(category.lowercased()) || recordCategory.caseInsensitiveCompare(category) == .orderedSame
                }
            }
        default: ()
        }
        
        return filteredRecords
    }
}
