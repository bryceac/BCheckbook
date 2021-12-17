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
    @StateObject var databaseManager: DBManager
    
    let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(records).environmentObject(databaseManager)
        }
    }
    
    init() {
        do {
            _databaseManager = try StateObject(wrappedValue: DBManager(withDB: DOCUMENTS_DIRECTORY.appendingPathComponent("register").appendingPathExtension("db")))
        } catch (let error) {
            print("Cannot open database")
        }
    }
}

