//
//  RecordView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var record: Record
    
    @State var credit: Double {
        didSet {
            if credit > 0 {
                debit = 0
                record.event.type = .deposit
            }
        }
    }
    
    @State var debit: Double {
        didSet {
            if debit > 0 {
                credit = 0
                record.event.type = .withdrawal
            }
        }
    }
    
    var body: some View {
        HStack {
            DatePicker("", selection: $record.event.date, displayedComponents: [.date])
            
            TextField("Check No.", value: $record.event.checkNumber, formatter: NumberFormatter())
            
            VStack {
                TextField("Vendor", text: $record.event.vendor)
                
                TextField("Memo", text: $record.event.memo)
            }
            
            TextField("Credit", value: $credit, formatter: NumberFormatter())
            
            TextField("Withdrawal", value: $debit, formatter: NumberFormatter())
            
            if let BALANCE_VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: record.balance)) {
                Text(BALANCE_VALUE)
            }
            
        }
    }
    
    init(record: Record) {
        self.record = record
        
        self._credit = EventType.deposit ~= record.event.type ? State(initialValue: record.event.amount) : State(initialValue: 0)
        
        self._debit = EventType.deposit ~= record.event.type ? State(initialValue: record.event.amount) : State(initialValue: 0)
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: Record())
    }
}
