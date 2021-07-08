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
        if let jsonData = configuration.file.regularFileContents {
            let SAVED_RECORDS = try Record.load(from: jsonData)
            
            for record in SAVED_RECORDS {
                records.add(record)
            }
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let JSON_ENCODER = JSONEncoder()
        JSON_ENCODER.outputFormatting = .prettyPrinted
        
        let ENCODED_RECORDS = try JSON_ENCODER.encode(records.sortedRecords)
        
        return FileWrapper(regularFileWithContents: ENCODED_RECORDS)
    }

}
