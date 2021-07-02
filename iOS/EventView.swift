//
//  EventView.swift
//  Checkbook (iOS)
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct RecordDetailView: View {
    @ObservedObject var record: Record
    
    var body: some View {
        Form {
            DatePicker("Date", selection: $record.event.date, displayedComponents: [.date])
            
            TextField("Check No.", value: $record.event.checkNumber, formatter: NumberFormatter())
            
            TextField("Vendor", text: $record.event.vendor)
            TextField("Memo", text: $record.event.memo)
            TextField("Amount", value: $record.event.amount, formatter: NumberFormatter())
            
            Picker("Type", selection: $record.event.type) {
                ForEach(EventType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            
            Toggle("Reconciled", isOn: $record.event.isReconciled)
        }
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(record: .constant(Record()))
    }
}
