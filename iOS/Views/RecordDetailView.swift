//
//  EventView.swift
//  Checkbook (iOS)
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct RecordDetailView: View {
    @ObservedObject var record: Record
    
    var checkNumberProxy: Binding<String> {
        Binding<String>(get: {
            var value = ""
            
            if let checkNumber = record.event.checkNumber {
                value = "\(checkNumber)"
            }
            
            return value
        }) { value in
            record.event.checkNumber = Int(value)
        }
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
        Form {
            DatePicker("Date", selection: $record.event.date, displayedComponents: [.date])
            
            TextField("Check No.", text: checkNumberProxy).keyboardType(.numberPad)
            
            TextField("Vendor", text: $record.event.vendor)
            TextField("Memo", text: $record.event.memo)
            TextField("Amount", value: $record.event.amount, formatter: Event.CURRENCY_FORMAT)
            
            Picker("Type", selection: $record.event.type) {
                ForEach(EventType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            
            OptionalComboBox(selection: $record.event.category, choices: categoryListBinding)
            
            Toggle("Reconciled", isOn: $record.event.isReconciled)
        }
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(record: Record())
    }
}
