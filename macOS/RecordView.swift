//
//  RecordView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var record: Record
    
    @State var credit: Double
    
    @State var debit: Double
    
    var body: some View {
        HStack {
            DatePicker("", selection: $record.event.date, displayedComponents: [.date])
            
            TextField("Check No.", value: $record.event.checkNumber, formatter: NumberFormatter())
            
            Toggle("Reconciled", isOn: $record.event.isReconciled)
            
            VStack {
                TextField("Vendor", text: $record.event.vendor)
                
                TextField("Memo", text: $record.event.memo)
            }
            
            TextField("Credit", value: $credit, formatter: NumberFormatter()).onChange(of: credit, perform: { value in
                
                if value > 0 {
                    if value != record.event.amount {
                        record.event.amount = value
                    }
                    
                    record.event.type = .deposit
                }
                
            })
            
            TextField("Withdrawal", value: $debit, formatter: NumberFormatter()).onChange(of: debit, perform: { value in
                
                if value > 0 {
                    if value != record.event.amount {
                        record.event.amount = value
                    }
                    
                    record.event.type = .withdrawal
                }
            })
            
            if let BALANCE_VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: record.balance)) {
                Text(BALANCE_VALUE)
            }
            
        }
    }
    
    init(record: Record) {
        self.record = record
        
        self._credit = EventType.deposit ~= record.event.type ? State(initialValue: record.event.amount) : State(initialValue: 0)
        
        self._debit = EventType.withdrawal ~= record.event.type ? State(initialValue: record.event.amount) : State(initialValue: 0)
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: Record( transaction: Event(amount: 200)))
    }
}
