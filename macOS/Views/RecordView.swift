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
            
            VStack {
                Text("Check No.")
                TextField("", value: $record.event.checkNumber, formatter: NumberFormatter())
            }
            
            VStack {
                Text("Reconciled")
                Toggle("", isOn: $record.event.isReconciled)
            }
            
            VStack {
                Text("Vendor")
                TextField("", text: $record.event.vendor)
                
                Text("Memo")
                TextField("", text: $record.event.memo)
            }
            
            VStack {
                Text("Credit")
                TextField("", value: $credit, formatter: Event.CURRENCY_FORMAT).onChange(of: credit, perform: { value in
                
                        if value > 0 {
                            if value != record.event.amount {
                                record.event.amount = value
                            }
                    
                            debit = 0
                    
                            record.event.type = .deposit
                        }
                
                    credit = value
                
                })
            }
            
            VStack {
                Text("Withdrawal")
                TextField("", value: $debit, formatter: Event.CURRENCY_FORMAT).onChange(of: debit, perform: { value in
                
                    if value > 0 {
                        if value != record.event.amount {
                            record.event.amount = value
                        }
                    
                        credit = 0
                    
                        record.event.type = .withdrawal
                    }
                
                    debit = value
                })
            }
            
            VStack(spacing: 10) {
                Text("Balance")
                if let BALANCE_VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: record.balance)) {
                    Text(BALANCE_VALUE)
                }
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
