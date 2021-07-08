//
//  BCheckFile.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/8/21.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct BCheckFile: FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    
    var records: Records = Records()
    
    init(configuration: ReadConfiguration) throws {
        let SAVED_RECORDS = Record.load(from: configuration.file.)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        <#code#>
    }

}
