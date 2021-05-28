//
//  RecordView.swift
//  Checkbook (iOS)
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var record: Record
    var body: some View {
        HStack {
            Text(Event.DF.string(from: record.transaction.date))
            
            if let checkNumber = record.transaction.checkNumber {
                Text("\(checkNumber)")
            }
            
            Text(record.transaction.isReconciled ? "Y" : "N")
            
            VStack {
                Text(record.transaction.vendor)
                Text(record.transaction.memo)
            }
            
            switch record.transaction.type {
            case .deposit:
                if let value = Event.CURRENCY_FORMAT.string(from: record.transaction.amount as NSNumber) {
                    Text(value)
                }
                
                Text("N/A")
            case .withdrawal:
                Text("N/A")
                
                if let value = Event.CURRENCY_FORMAT.string(from: record.transaction.amount as NSNumber) {
                    Text(value)
                }
            }
            
            if let value = Event.CURRENCY_FORMAT.string(from: record.balance as NSNumber) {
                Text(value)
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(record: Record())
    }
}
