//
//  RecordView.swift
//  Checkbook (iOS)
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var record: Record
    var balance: Double = 0
    
    var body: some View {
        VStack {
            Text(Event.DF.string(from: record.event.date))
                
            if let checkNumber = record.event.checkNumber {
                HStack {
                    Text("Check #")
                    Text("\(checkNumber)")
                }
            }
            
            HStack {
                Text("Reconciled?")
                Text(record.event.isReconciled ? "Y" : "N")
            }
            
                
            HStack {
                Text("Vendor:")
                Text(record.event.vendor)
            }
            
            HStack {
                Text("Memo:")
                Text(record.event.memo)
            }
            
                
            switch record.event.type {
                case .deposit:
                
                    HStack {
                        Text("Credit:")
                        if let value = Event.CURRENCY_FORMAT.string(from: record.event.amount as NSNumber) {
                            Text(value)
                        }
                    }
                
                    HStack {
                        Text("Withdrawal:")
                        Text("N/A")
                    }
                    
                    
                    
                case .withdrawal:
                HStack {
                    Text("Credit:")
                    Text("N/A")
                }
            
                HStack {
                    Text("Withdrawal:")
                    if let value = Event.CURRENCY_FORMAT.string(from: record.event.amount as NSNumber) {
                        Text(value)
                    }
                }
            }
            
            HStack {
                Text("Balance:")
                if let VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: balance)) {
                    Text(VALUE)
                }
            }
            
            HStack {
                Text("Category:")
                Text(record.event.category ?? "Uncategorized")
            }
            
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: Record())
    }
}
