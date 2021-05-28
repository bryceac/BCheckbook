//
//  CheckbookApp.swift
//  Shared
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

@main
struct CheckbookApp: App {
    @StateObject var records: GetRecords = GetRecords()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(records)
        }
    }
}
