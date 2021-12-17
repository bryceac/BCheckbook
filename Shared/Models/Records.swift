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
            items.forEach { record in
                let cancellable = record.objectWillChange.sink { _ in
                    self.objectWillChange.send()
                }
                
                cancellables.append(cancellable)
            }
        }
    }
    
    var cancellables: [AnyCancellable] = []
    
    var databaseManager: DBManager
    
    init(withRecords records: [Record] = [], databaseLocation: URL) throws {
        items = records
        databaseManager = DBManager(withDB: databaseLocation)
    }
    
    func add(_ record: Record) {
        items.append(record)
    }
    
    func remove(at index: Int) {
        items.remove(at: index)
    }
    
    func clear() {
        items.removeAll()
    }
    
    func element(matching record: Record) -> Record? {
        guard items.contains(record) else { return nil }
        
        return items.first(where: { $0 == record })
    }
}
