//
//  DocumentScene.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/8/21.
//

import Foundation
import SwiftUI

struct DocumentScene: Scene {
    var body: some Scene {
        DocumentGroup(viewing: BCheckFileDocument.self) { file in
            ContentView(bcheckFile: file.$document)
        }
    }
}
