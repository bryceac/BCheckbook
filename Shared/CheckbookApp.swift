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
    @State var showNewFileAlert = false
    
    let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            if let filePath = file, let displayName = Bundle.main.displayName {
                ContentView().environmentObject(records).navigationTitle("\(filePath.path) - \(displayName)").alert(isPresented: $showNewFileAlert, content: {
                    Alert(title: Text("Create New Register"), message: Text("You are about to create a new register, which will override the current view. Do you want to continue?"), primaryButton: .default(Text("Yes"), action: {
                        self.file = nil
                        self.records.clear()
                        self.showNewFileAlert = false
                    }), secondaryButton: .default(Text("No"), action: {
                        self.showNewFileAlert = false
                    }))
                })
            } else if let displayName = Bundle.main.displayName {
                ContentView().environmentObject(records).navigationTitle("New Register - \(displayName)")
            }
            #else
            ContentView().environmentObject(records)
            #endif
        }.commands {
            #if os (macOS)
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("New") {
                    self.showNewFileAlert = true
                }.keyboardShortcut(KeyEquivalent("n"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
            
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button("Open") {
                    open()
                }.keyboardShortcut(KeyEquivalent("o"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
            
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Save") {
                    if let file = file {
                        try? records.sortedRecords.save(to: file)
                    } else {
                        saveAs()
                    }
                }.keyboardShortcut(KeyEquivalent("s"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
                
                Button("Save As") {
                    saveAs()
                }.keyboardShortcut(KeyEquivalent("s"), modifiers: [.option, .command, .shift])
            }
            #endif
        }
    }
    
    func saveAs() {
        #if os(macOS)
        let SAVE_PANEL = NSSavePanel()
        SAVE_PANEL.allowedFileTypes = ["bcheck"]
        SAVE_PANEL.showsHiddenFiles = true
        SAVE_PANEL.showsResizeIndicator = true
        SAVE_PANEL.canCreateDirectories = true
        SAVE_PANEL.directoryURL = DOCUMENTS_DIRECTORY
        SAVE_PANEL.nameFieldStringValue = "transactions"
        SAVE_PANEL.begin { result in
            if case NSApplication.ModalResponse.OK = result, let filePath = SAVE_PANEL.url {
                try? records.sortedRecords.save(to: filePath)
                
                file = filePath
            }
        }
        #endif
    }
    
    func open() {
        #if os(macOS)
        records.clear()
        let OPEN_PANEL = NSOpenPanel()
        OPEN_PANEL.allowedFileTypes = ["bcheck"]
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
        #endif
    }
}

