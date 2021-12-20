//
//  RecordView.swift
//  Checkbook (iOS)
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var record: Record
    
    var balance: Double {
        return record.balance
    }
    
    var body: some View {
        HStack {
            Text(Event.DF.string(from: record.event.date))
            
            if let checkNumber = record.event.checkNumber {
                Text("\(checkNumber)")
            }
            
            Text(record.event.isReconciled ? "Y" : "N")
            
            VStack {
                Text(record.event.vendor)
                Text(record.event.memo)
            }
            
            switch record.event.type {
            case .deposit:
                if let value = Event.CURRENCY_FORMAT.string(from: record.event.amount as NSNumber) {
                    Text(value)
                }
                
                Text("N/A")
            case .withdrawal:
                Text("N/A")
                
                if let value = Event.CURRENCY_FORMAT.string(from: record.event.amount as NSNumber) {
                    Text(value)
                }
            }
            
            if let VALUE = Event.CURRENCY_FORMAT.string(from: NSNumber(value: balance)) {
                Text(VALUE)
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: Record())
    }
}
