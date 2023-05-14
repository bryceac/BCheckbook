//
//  GetRecords.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation
import Combine
import UniformTypeIdentifiers
import IdentifiedCollections
import CoreTransferable

class Records: ObservableObject LosslessStringConvertible {
    @Published var items: IdentifiedArrayOf<Record> {
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
        return items.map { $0 }.sorted { firstRecord, secondRecord in
            firstRecord.event.date < secondRecord.event.date
        }
    }
    
    var exportFormat: UTType? = nil
    
    
    init(withRecords records: [Record] = []) {
        items = IdentifiedArrayOf(uniqueElements: records)
    }
    
    required convenience init?(_ description: String) {
        let STORED_RECORDS = description.components(separatedBy: "\r\n")
        
        let RETRIEVED_RECORDS = STORED_RECORDS.compactMap { line in
            Record(line)
        }
        
        guard !RETRIEVED_RECORDS.isEmpty else { return nil }
        
        self.init(withRecords: RETRIEVED_RECORDS)
    }
    
    func balance(for record: Record) -> Double {
        guard let databaseManager = DB.shared.manager, let balance = try? databaseManager.balance(for: record) else { return 0 }
        
        return balance
    }
    
    func add(_ record: Record) {
        items.append(record)
    }
    
    func add(_ records: [Record]) {
        items.append(contentsOf:records)
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
                    return (record.event.vendor.lowercased().contains(vendor.lowercased()) || record.event.vendor.caseInsensitiveCompare(vendor) == .orderedSame) &&
                        .none ~= record.event.category
                } else {
                    guard let recordCategory = record.event.category else { return false }
                    
                    return (record.event.vendor.lowercased().contains(vendor.lowercased()) || record.event.vendor.caseInsensitiveCompare(vendor) == .orderedSame) &&
                    (recordCategory.lowercased().contains(category.lowercased()) || recordCategory.caseInsensitiveCompare(category) == .orderedSame)
                }
                
            }
        case let (.some(vendor), .none):
            filteredRecords = filteredRecords.filter { $0.event.vendor.lowercased().contains(vendor.lowercased()) || $0.event.vendor.caseInsensitiveCompare(vendor) == .orderedSame }
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

extension Records: CustomStringConvertible {
    var description: String {
        sortedRecords.map { record in
            "\(record)"
        }.joined(separator: "\r\n")
    }
}

extension Records: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .bcheckFile)
        ProxyRepresentation { store in
            return "\(store)"
        }
    }
}
