//
//  RecordTable.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/19/22.
//

import SwiftUI

struct RecordTable: View {
    @EnvironmentObject var records: Records
    
    @State private var order = [
        KeyPathComparator(\Record.event.date, order: .forward)
    ]
    
    @Binding var selectedRecords: Set<Record.ID>
    
    @Binding var query: String
    
    @State var displayedRecords: [Record] = []
    
    var filteredRecords: [Record] {
        guard !query.isEmpty else { return records.sortedRecords }
        
        var requestedRecords: [Record] = []
        
        
        switch (query) {
        case let text where text.starts(with: "category:"):
            if let categoryPattern = text.matching(regexPattern: "category:\\s(.*)"), !categoryPattern.isEmpty, categoryPattern[0].indices.contains(1) {
                let specifiedCategory = categoryPattern[0][1]
                
                requestedRecords = records.filter(category: specifiedCategory)
            }
        case let text where text.contains(" category:"):
            if let categoryRange = text.range(of: "category:"), let categoryPattern = text.matching(regexPattern: "category:\\s(.*)"), !categoryPattern.isEmpty, categoryPattern[0].indices.contains(1) {
                let specifiedCategory = categoryPattern[0][1]
                var vendor = String(text[..<categoryRange.lowerBound])
                
                if let lastCharacter = vendor.last, lastCharacter.isWhitespace {
                    vendor = String(vendor.dropLast())
                }
                
                requestedRecords = records.filter(vendor: vendor, category: specifiedCategory)
            }
        default:
            requestedRecords = records.filter(vendor: query)
        }
        
        return requestedRecords
    }
    
    var categoryListBinding: Binding<[String]> {
            Binding(get: {
                guard let databaseManager = DB.shared.manager, let categories = databaseManager.categories else { return [] }
                return categories.sorted()
            }, set: { newValue in
                guard let databaseManager = DB.shared.manager else { return }
                
                try? databaseManager.add(categories: newValue)
            })
        }
    
    var body: some View {
        Table(displayedRecords, selection: $selectedRecords, sortOrder: $order) {
            TableColumn("Date", value: \Record.event.date) { record in

                DatePicker("Date", selection: recordBinding(record.id).event.date, displayedComponents: [.date])
            }
            
            TableColumn("Check #", value: \Record.event.checkNumber, comparator: OptionalComparator<Int>()) { record in

                TextField("", text: checkNumberBinding(record.id))

            }
            
            TableColumn("Reconciled", value: \Record.event.isReconciled, comparator: BoolComparator()) { record in
                
                Toggle("", isOn: recordBinding(record.id).event.isReconciled)
            }
            
            TableColumn("Category", value: \Record.event.category, comparator: OptionalComparator<String>()) { record in

                OptionalComboBox(selection: recordBinding(record.id).event.category, choices: categoryListBinding)
            }
            
            TableColumn("Vendor", value: \Record.event.vendor) { record in
                
                TextField("", text: recordBinding(record.id).event.vendor)
            }
            
            TableColumn("Memo", value: \Record.event.memo) { record in
                
                TextField("", text: recordBinding(record.id).event.memo)
            }
            
            TableColumn("Credit", value: \Record.event.amount) { record in
                
                TextField("", value: creditBinding(record.id), formatter: Event.CURRENCY_FORMAT)
            }
            
            TableColumn("Withdrawal", value: \Record.event.amount) { record in
                
                TextField("", value: withdrawalBinding(record.id), formatter: Event.CURRENCY_FORMAT)
            }
            
            TableColumn("Balance", value: \Record.self) { record in
                
                if let BALANCE_VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: records.balance(for: record))) {
                    Text(BALANCE_VALUE)
                }
            }
        }.onChange(of: order) { newOder in
            displayedRecords.sort(using: newOder)
        }
    }
    
    func recordBinding(_ id: Record.ID) -> Binding<Record> {
        var placeholder = Record(withID: "FF04C3DC-F0FE-472E-8737-0F4034C049F0", transaction: Event(date: Date(), checkNumber: 1260, vendor: "Sam Hill Credit Union", memo: "Open Account", amount: 500, type: .deposit, isReconciled: true))
        
        var recordBinding: Binding<Record>!
        
        if var record = records.items[id: id] {
            recordBinding = Binding(get: {
                record
            }, set: { newRecord in
                record = newRecord
            })
        } else {
            recordBinding = Binding(get: {
                placeholder
            }, set: { newRecord in
                placeholder = newRecord
            })
        }
        
        return recordBinding
    }
    
    func checkNumberBinding(_ id: Record.ID) -> Binding<String> {
        
        return Binding {
            if let checkNumber = recordBinding(id).wrappedValue.event.checkNumber {
                return "\(checkNumber)"
            } else {
                return ""
            }
        } set: { newCheckNumber in
            recordBinding(id).wrappedValue.event.checkNumber = Int(newCheckNumber)
        }

    }
    
    func creditBinding(_ id: Record.ID) -> Binding<Double> {
        
        return Binding {
            guard case EventType.deposit = recordBinding(id).wrappedValue.event.type else { return 0 }
            
            return recordBinding(id).wrappedValue.event.amount
        } set: { newAmount in
            recordBinding(id).wrappedValue.event.type = .deposit
            
            recordBinding(id).wrappedValue.event.amount = newAmount
        }
    }
    
    func withdrawalBinding(_ id: Record.ID) -> Binding<Double> {
        
        return Binding {
            guard case EventType.withdrawal = recordBinding(id).wrappedValue.event.type else { return 0 }
            
            return recordBinding(id).wrappedValue.event.amount
        } set: { newAmount in
            recordBinding(id).wrappedValue.event.type = .withdrawal
            
            recordBinding(id).wrappedValue.event.amount = newAmount
        }
    }
}

extension RecordTable {
    init(selection selectedRecords: Binding<Set<Record.ID>>, filter query: Binding<String>) {
        self._selectedRecords = selectedRecords
        
        self._query = query
        
        displayedRecords = filteredRecords
    }
}

struct RecordTableView_Previews: PreviewProvider {
    static var previews: some View {
        RecordTable(selectedRecords: .constant(Set<Record.ID>()), query: .constant(""))
    }
}
