//
//  CheckbookApp.swift
//  Shared
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

@main
struct CheckbookApp: App {
    
    var body: some Scene {
        WindowGroup {
            TabView{
                ContentView().tabItem {
                    Image(systemName: "list.dash")
                    Text("Ledger")
                }.navigationTitle("Ledger")
                
                SummaryView().tabItem {
                    Image(systemName: "tablecells")
                    Text("Summary")
                }.navigationTitle("Summary")
            }
            
        }
    }
}

