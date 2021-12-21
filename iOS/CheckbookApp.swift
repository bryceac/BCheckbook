//
//  CheckbookApp.swift
//  Shared
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

@main
struct CheckbookApp: App {
    
    @StateObject var document: BCheckFileDocument = BCheckFileDocument()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(document).onOpenURL { fileURL in
                guard let databaseManager = DB.shared.manager, let savedRecords = try? Record.load(from: fileURL) else { return }
                
                try? databaseManager.add(records: savedRecords)
                document.records.items = savedRecords
            }
        }
    }
}

