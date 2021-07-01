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
    
    let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(records)
        }.commands {
            #if os (macOS)
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button("Open") {
                    open()
                }.keyboardShortcut(KeyEquivalent("o"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
            
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Save") {
                    if let file = file {
                        try? records.items.save(to: file)
                    } else {
                        saveAs()
                    }
                }.keyboardShortcut(KeyEquivalent("s"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
                
                Button("Save As") {
                    saveAs()
                }.keyboardShortcut(KeyEquivalent("s"), modifiers: [.option, .command, .shift])
            }
            
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("New") {
                    file = nil
                    records.items = [Record]()
                }.keyboardShortcut(KeyEquivalent("n"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
            #endif
        }
    }
    
    func saveAs() {
        let SAVE_PANEL = NSSavePanel()
        SAVE_PANEL.allowedFileTypes = ["json"]
        SAVE_PANEL.showsHiddenFiles = true
        SAVE_PANEL.showsResizeIndicator = true
        SAVE_PANEL.canCreateDirectories = true
        SAVE_PANEL.directoryURL = DOCUMENTS_DIRECTORY
        SAVE_PANEL.nameFieldStringValue = "transactions"
        SAVE_PANEL.begin { result in
            if case NSApplication.ModalResponse.OK = result, let filePath = SAVE_PANEL.url {
                try? records.items.save(to: filePath)
                
                file = filePath
            }
        }
    }
    
    func open() {
        records.items.removeAll()
        
        let OPEN_PANEL = NSOpenPanel()
        OPEN_PANEL.allowedFileTypes = ["json"]
        OPEN_PANEL.showsHiddenFiles = true
        OPEN_PANEL.canChooseDirectories = true
        OPEN_PANEL.showsResizeIndicator = true
        OPEN_PANEL.allowsMultipleSelection = false
        OPEN_PANEL.directoryURL = DOCUMENTS_DIRECTORY
        OPEN_PANEL.begin { result in
            if case NSApplication.ModalResponse.OK = result, let filePath = OPEN_PANEL.url, let SAVED_RECORDS = try? Record.load(from: filePath) {
                
                for record in SAVED_RECORDS {
                    records.add(record)
                }
                
                file = filePath
            }
        }
    }
}

