//
//  RecordTableView.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/19/22.
//

import SwiftUI

struct RecordTableView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var records = []
    @State private var order = [
        KeyPathComparator(\Record.event.date, order: .forward)
    ]
    
    @State private var selectedRecords = Set<Record.ID>()
    
    var categoryListBinding: Binding<[String]> {
            Binding(get: {
                guard let databaseManager = DB.shared.manager, let categories = databaseManager.categories else { return [] }
                return categories.sorted()
            }, set: { newValue in
                guard let databaseManager = DB.shared.manager else { return }
                
                try? databaseManager.add(categories: newValue)
            })
        }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RecordTableView_Previews: PreviewProvider {
    static var previews: some View {
        RecordTableView()
    }
}
