//
//  CheckbookApp.swift
//  Shared
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

@main
struct CheckbookApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView().tabItem {
                    Image(systemName: "list.dash")
                    Text("Ledger")
                }
                SummaryView().tabItem {
                    Image(systemName: "tablecells")
                    Text("Summary")
                }
            }.frame(minWidth: 800, minHeight: 600)
        }
    }
}

