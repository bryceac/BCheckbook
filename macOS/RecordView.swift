//
//  RecordView.swift
//  Checkbook (macOS)
//
//  Created by Bryce Campbell on 6/30/21.
//

import SwiftUI

struct RecordView: View {
    @Binding var record: Record {
        didSet {
            switch record.event.type {
            case .deposit: credit = record.event.amount
            case .withdrawal: debit = record.event.amount
            }
        }
    }
    
    @State var credit: Double = 0 {
        willSet {
            if newValue > 0 {
                debit = 0
                record.event.type = .deposit
            }
        }
    }
    
    @State var debit: Double = 0 {
        willSet {
            if newValue > 0 {
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
                TextField("Balance", text: .constant(BALANCE_VALUE))
            }
            
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: .constant(Record()))
    }
}
