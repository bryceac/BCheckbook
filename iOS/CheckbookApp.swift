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
        if let BUNDLE_PATH = Bundle.main.url(forResource: DB.shared.url.deletingPathExtension().lastPathComponent, withExtension: DB.shared.url.pathExtension) {
            try? FileManager.default.copyItem(at: BUNDLE_PATH, to: DB.shared.url)
        }
    }
}

