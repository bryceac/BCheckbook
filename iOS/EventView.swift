//
//  EventView.swift
//  Checkbook (iOS)
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct RecordDetailView: View {
    @Binding var transaction: Event
    
    var body: some View {
        Form {
            DatePicker("Date", selection: $transaction.date, displayedComponents: [.date])
            
            TextField("Check No.", value: $transaction.checkNumber, formatter: NumberFormatter())
            
            TextField("Vendor", text: $transaction.vendor)
            TextField("Memo", text: $transaction.memo)
            TextField("Amount", value: $transaction.amount, formatter: NumberFormatter())
            
            Picker("Type", selection: $transaction.type) {
                ForEach(EventType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            
            Toggle("Reconciled", isOn: $transaction.isReconciled)
        }
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(transaction: .constant(Event()))
    }
}
