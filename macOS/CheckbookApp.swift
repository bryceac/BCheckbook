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
    
    @StateObject var records = Records()
    
    var body: some Scene {
        WindowGroup {
            ContentView().frame(minWidth: 1024, minHeight: 768).environmentObject(records)
        }
        
        WindowGroup("Summary") {
            SummaryView().frame(minWidth: 800, minHeight: 600).handlesExternalEvents(preferring: Set(arrayLiteral: "summary"), allowing: Set(arrayLiteral: "*"))
        }.handlesExternalEvents(matching: Set(arrayLiteral: "summary"))
    }
}

