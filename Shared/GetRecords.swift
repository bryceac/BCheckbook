//
//  GetRecords.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

class GetRecords: ObservableObject {
    @Published var items: [Record]
    
    init(withRecords records: [Record] = []) {
        items = records
    }
}
