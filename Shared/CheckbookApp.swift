//
//  CheckbookApp.swift
//  Shared
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

@main
struct CheckbookApp: App {
    @StateObject var records: Records = Records()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(records)
        }
    }
    
    init() {
        let DOCUMENTS_DIECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        #if os(iOS)
        if let SAVED_RECORDS = try? Record.load(from: DOCUMENTS_DIECTORY.appendingPathComponent("transactions").appendingPathExtension("json")) {
            
            for record in SAVED_RECORDS {
                records.add(record)
            }
        }
        #endif
    }
}
