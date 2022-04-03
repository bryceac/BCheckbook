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
        VStack(spacing: 10) {
            Text(Event.DF.string(from: record.event.date))
                
            if let checkNumber = record.event.checkNumber {
                HStack {
                    Text("Check #").bold()
                    Spacer()
                    Text("\(checkNumber)")
                }
            }
            
            HStack {
                Text("Reconciled").bold()
                Spacer()
                Text(record.event.isReconciled ? "Y" : "N")
            }
            
                
            HStack {
                Text("Vendor").bold()
                Spacer()
                Text(!record.event.vendor.isEmpty ? record.event.vendor : "N/A")
            }
            
            HStack {
                Text("Memo").bold()
                Spacer()
                Text(!record.event.memo.isEmpty ? record.event.memo : "N/A")
            }
            
                
            switch record.event.type {
                case .deposit:
                
                    HStack {
                        Text("Credit").bold()
                        Spacer()
                        if let value = Event.CURRENCY_FORMAT.string(from: record.event.amount as NSNumber) {
                            Text(value)
                        }
                    }
                
                    HStack {
                        Text("Withdrawal").bold()
                        Spacer()
                        Text("N/A")
                    }
                    
                    
                    
                case .withdrawal:
                HStack {
                    Text("Credit").bold()
                    Spacer()
                    Text("N/A")
                }
            
                HStack {
                    Text("Withdrawal").bold()
                    Spacer()
                    if let value = Event.CURRENCY_FORMAT.string(from: record.event.amount as NSNumber) {
                        Text(value)
                    }
                }
            }
            
            HStack {
                Text("Balance").bold()
                Spacer()
                if let VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: balance)) {
                    Text(VALUE)
                }
            }
            
            HStack {
                Text("Category").bold()
                Spacer()
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
