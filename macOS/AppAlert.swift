//
//  AppAlert.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/8/21.
//

import Foundation
import SwiftUI

enum AppAlert: Identifiable {
    case unsavedChanges(path: URL? = nil, confirmHandler: () -> Void, cancelHandler: () -> Void), creatingNewFile(confirmHandler: () -> Void, cancelHandler: () -> Void)
    
    var alert: Alert {
        switch self {
        case let .creatingNewFile(confirmHandler, cancelHander): return Alert(title: Text("Create New Register"), message: Text("You are about to create a new register, which will override the current view. Do you want to continue?"), primaryButton: .default(Text("No"), action: {
            cancelHander()
        }), secondaryButton: .default(Text("Yes"), action: {
            confirmHandler()
        }))
        case let .unsavedChanges(filePath, confirmHandler, cancelHandler): return Alert(title: Text("Unsaved Changes"), message: Text("There are changes not saved. Do you want to save \(filePath?.lastPathComponent ?? "these changes")"), primaryButton: .default(Text("No"), action: {
            cancelHandler()
        }), secondaryButton: .default(Text("Yes"), action: {
            confirmHandler()
        }))
        }
    }
    
    var id: String {
        switch self {
        case .unsavedChanges(_, _, _): return "unsavedChanges"
        case .creatingNewFile(_, _): return "creatingNewFile"
        }
    }
}
