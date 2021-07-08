//
//  BCheckFile.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/8/21.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

extension UTType {
    static var bcheckFiles: UTType {
        UTType(importedAs: "me.brycecampbell.bcheck")
    }
}

struct BCheckFileDocument: FileDocument {
    
    
    static var readableContentTypes: [UTType] = [.bcheckFiles]
    
    var records: Records = Records()
    
    init(records: Records = Records()) {
        self.records = records
    }
    
    init(configuration: ReadConfiguration) throws {
        if let jsonData = configuration.file.regularFileContents {
            let SAVED_RECORDS = try Record.load(from: jsonData)
            
            self.init(records: Records(withRecords: SAVED_RECORDS))
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        <#code#>
    }
}