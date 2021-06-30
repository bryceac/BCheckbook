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
    
    @State var file: URL? = nil
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(records)
        }.commands {
            #if os (macOS)
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Save") {
                    if let file = file {
                        try? records.items.save(to: file)
                    } else {
                        saveAs()
                    }
                }
            }
            #endif
        }
    }
    
    func saveAs() {
        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let SAVE_PANEL = NSSavePanel()
        SAVE_PANEL.allowedFileTypes = ["json"]
        SAVE_PANEL.showsHiddenFiles = true
        SAVE_PANEL.showsResizeIndicator = true
        SAVE_PANEL.canCreateDirectories = true
        SAVE_PANEL.directoryURL = DOCUMENTS_DIRECTORY
        SAVE_PANEL.nameFieldStringValue = "transaction"
        SAVE_PANEL.begin { result in
            if case NSApplication.ModalResponse.OK = result, let filePath = SAVE_PANEL.url {
                try? records.items.save(to: filePath)
                
                file = filePath
            }
        }
    }
}

