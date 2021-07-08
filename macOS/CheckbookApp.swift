//
//  CheckbookApp.swift
//  Shared
//
//  Created by Bryce Campbell on 5/27/21.
//

import SwiftUI

@main
struct CheckbookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            /* CommandGroup(replacing: CommandGroupPlacement.newItem) {
                Button("New") {
                    appAlert = AppAlert.creatingNewFile(confirmHandler: {
                        appAlert = nil
                        file = nil
                        records.clear()
                    }, cancelHandler: {
                        appAlert = nil
                    })
                }.keyboardShortcut(KeyEquivalent("n"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
            
            CommandGroup(replacing: CommandGroupPlacement.appTermination) {
                Button("Quit") {
                    if let filePath = file, let savedRecords = try? Record.load(from: filePath) {
                        if records.sortedRecords != savedRecords {
                            appAlert = AppAlert.unsavedChanges(path: file, confirmHandler: {
                                appAlert = nil
                                save()
                                NSApplication.shared.terminate(self)
                            }, cancelHandler: {
                                appAlert = nil
                                NSApplication.shared.terminate(self)
                            })
                        }
                    } else if !records.sortedRecords.isEmpty && .none ~= file {
                        appAlert = AppAlert.unsavedChanges(confirmHandler: {
                            appAlert = nil
                            saveAs()
                            NSApplication.shared.terminate(self)
                        }, cancelHandler: {
                            appAlert = nil
                            NSApplication.shared.terminate(self)
                        })
                    }
                    
                }.keyboardShortcut(KeyEquivalent("q"), modifiers: .command)
            }
            
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button("Open") {
                    open()
                }.keyboardShortcut(KeyEquivalent("o"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
            
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Save") {
                    save()
                }.keyboardShortcut(KeyEquivalent("s"), modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
                
                Button("Save As") {
                    saveAs()
                }.keyboardShortcut(KeyEquivalent("s"), modifiers: [.option, .command, .shift])
            } */
        }
    }
}

