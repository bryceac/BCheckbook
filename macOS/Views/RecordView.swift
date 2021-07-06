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
    
    var checkProxy: Binding<String> {
        Binding<String>(get: {
            var value = ""
            
            if let checkNumber = record.event.checkNumber {
                value = "\(checkNumber)"
            }
            
            return value
        }) { value in
            if let numberValue = Int(value) {
                record.event.checkNumber = numberValue
            }
        }
    }
    
    var body: some View {
        HStack {
            DatePicker("", selection: $record.event.date, displayedComponents: [.date])
            
            VStack {
                Text("Check No.")
                TextField("", text: checkProxy).background(Color(red: 255/255, green: 255/255, blue: 255/255))
            }
            
            VStack {
                Text("Reconciled")
                Toggle("", isOn: $record.event.isReconciled)
            }
            
            VStack {
                Text("Vendor")
                TextField("", text: $record.event.vendor).background(Color(red: 255/255, green: 255/255, blue: 255/255))
                
                Text("Memo")
                TextField("", text: $record.event.memo).background(Color(red: 255/255, green: 255/255, blue: 255/255))
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
                
                }).background(Color(red: 255/255, green: 255/255, blue: 255/255))
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
                }).background(Color(red: 255/255, green: 255/255, blue: 255/255))
            }
            
            VStack(spacing: 10) {
                Text("Balance")
                if let BALANCE_VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: record.balance)) {
                    Text(BALANCE_VALUE)
                }
            }
            
        }.background(Color.init(red: 192/255, green: 192/255, blue: 192/255))
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
