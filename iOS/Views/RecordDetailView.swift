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
            
            Toggle("Reconciled", isOn: $record.event.isReconciled)
        }
    }
    
    func updateDB() {
        guard let databaseManager = DB.shared.manager else { return }
        
        try? databaseManager.update(record: record)
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(record: Record())
    }
}
