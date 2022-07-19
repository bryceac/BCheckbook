//
//  RecordTableView.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/19/22.
//

import SwiftUI

struct RecordTableView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var displayedRecords: [Record] = []
    @State private var order = [
        KeyPathComparator(\Record.event.date, order: .forward)
    ]
    
    @State private var selectedRecords = Set<Record.ID>()
    
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
                        .foregroundColor(Color.black)
                }
            }
        }    }
}

struct RecordTableView_Previews: PreviewProvider {
    static var previews: some View {
        RecordTableView()
    }
}
