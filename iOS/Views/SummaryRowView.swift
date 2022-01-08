//
//  SummaryRowView.swift
//  BCheckbook (iOS)
//
//  Created by Bryce Campbell on 1/8/22.
//

import SwiftUI

struct SummaryRowView: View {
    var title: String = "Hello"
    var tally: Double = 0
    
    var body: some View {
        HStack {
            Text(title).bold()
            
            if let tallyValue = Event.CURRENCY_FORMAT.string(from: NSNumber(value: tally)) {
                Text(tallyValue)
            }
        }
    }
}

struct SummaryRowView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryRowView()
    }
}
