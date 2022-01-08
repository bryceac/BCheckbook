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
                    Text("Ledger")
                }
                SummaryView().tabItem {
                    Text("Summary")
                }
            }
            
        }
    }
}

