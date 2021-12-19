//
//  EventView.swift
//  Checkbook (iOS)
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct RecordDetailView: View {
    @ObservedObject var record: Record
    var delegate: RecordDetailDelegate? = nil
    
    var dateBinding: Binding<Date> {
        Binding(get: {
            return record.event.date
        }, set: { newDate in
            record.event.date = newDate
            
            updateDB()
        })
    }
    
    var checkNumberProxy: Binding<String> {
        Binding<String>(get: {
            var value = ""
            
            if let checkNumber = record.event.checkNumber {
                value = "\(checkNumber)"
            }
            
            return value
        }) { value in
            record.event.checkNumber = Int(value)
            
            updateDB()
        }
    }
    
    var vendorBinding: Binding<String> {
        Binding(get: {
            return record.event.vendor
        }, set: { vendorValue in
            record.event.vendor = vendorValue
            
            updateDB()
        })
    }
    
    var memoBinding: Binding<String> {
        Binding(get: {
            return record.event.memo
        }, set: { memoValue in
            record.event.memo = memoValue
            
            updateDB()
        })
    }
    
    var amountBinding: Binding<Double> {
        Binding(get: {
            return record.event.amount
        }, set: { amountValue in
            record.event.amount = amountValue
            
            updateDB()
        })
    }
    
    var typeBinding: Binding<EventType> {
        Binding(get: {
            return record.event.type
        }, set: { typeValue in
            record.event.type = typeValue
            
            updateDB()
        })
    }
    
    var isReconciledBinding: Binding<Bool> {
        Binding(get: {
            return record.event.isReconciled
        }, set: { isReconciledValue in
            record.event.isReconciled = isReconciledValue
            
            updateDB()
        })
    }
    
    var body: some View {
        Form {
            DatePicker("Date", selection: dateBinding, displayedComponents: [.date])
            
            TextField("Check No.", text: checkNumberProxy).keyboardType(.numberPad)
            
            TextField("Vendor", text: vendorBinding)
            TextField("Memo", text: memoBinding)
            TextField("Amount", value: amountBinding, formatter: Event.CURRENCY_FORMAT)
            
            Picker("Type", selection: typeBinding) {
                ForEach(EventType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            
            Toggle("Reconciled", isOn: isReconciledBinding)
        }
    }
    
    func updateDB() {
        guard let databaseManager = DB.shared.manager else { return }
        
        try? databaseManager.update(record: record)
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(record: Record())
    }
}
