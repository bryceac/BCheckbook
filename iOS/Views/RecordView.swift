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
            
            if record.event.isReconciled {
                Image(systemName: "checkmark")
            }
            
                
            HStack {
                Text("Vendor").bold()
                Spacer()
                Text(!record.event.vendor.isEmpty ? record.event.vendor : "N/A")
            }
            
            if !record.event.memo.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                    Spacer()
                    Text(!record.event.memo.isEmpty ? record.event.memo : "N/A")
                }
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
            
            if let category = record.event.category {
                HStack {
                    Text("Category").bold()
                    Spacer()
                    Text(category)
                }
            }
            
            
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: Record())
    }
}
