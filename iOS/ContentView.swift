//
//  ContentView.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var records: GetRecords
    var body: some View {
        NavigationView {
            List {
                ForEach(records.items.indices, id: \.self) { index in
                    NavigationLink(
                        destination: EventView(transaction: $records.items[index]),
                        label: {
                            RecordView(record: records.items[index])
                        })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GetRecords(withRecords: [
        Record()
        ]))
    }
}
