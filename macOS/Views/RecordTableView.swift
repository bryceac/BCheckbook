//
//  RecordTableView.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/19/22.
//

import SwiftUI

struct RecordTableView: View {
    @State private var records = []
    @State private var order = [
        KeyPathComparator(\Record.event.date, order: .forward)
    ]
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RecordTableView_Previews: PreviewProvider {
    static var previews: some View {
        RecordTableView()
    }
}
