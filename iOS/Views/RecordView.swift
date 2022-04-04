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
        VStack(alignment: .leading, spacing: 10) {
            Text(Event.DF.string(from: record.event.date))
                
            if let checkNumber = record.event.checkNumber {
                    Text("\(checkNumber)")
            }
            
            if record.event.isReconciled {
                Image(systemName: "checkmark")
            }
            
            Text(!record.event.vendor.isEmpty ? record.event.vendor : "N/A")
            
            if !record.event.memo.isEmpty {
                    Text(!record.event.memo.isEmpty ? record.event.memo : "N/A")
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
            
            if let category = record.event.category {
                    Text(category)
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: Record())
    }
}
