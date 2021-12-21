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
            ContentView().environmentObject(document)
        }
    }
}

