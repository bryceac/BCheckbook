//
//  AppDelegate.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 12/21/21.
//

import Foundation
import AppKit
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
