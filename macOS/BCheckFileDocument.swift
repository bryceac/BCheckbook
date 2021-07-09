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

class BCheckFileDocument: ReferenceFileDocument {
    
    
    static var readableContentTypes: [UTType] = [.bcheckFiles]
    
    @Published var records: Records = Records()
    
    init(records: Records = Records()) {
        self.records = records
    }
    
    required convenience init(configuration: ReadConfiguration) throws {
        var records = Records()
        
        if let jsonData = configuration.file.regularFileContents {
            let SAVED_RECORDS = try Record.load(from: jsonData)
            
            records = Records(withRecords: SAVED_RECORDS)
        }
        
        self.init(records: records)
    }
    
    /* func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var fileWrapper = FileWrapper()
        
        if let JSON_DATA = records.sortedRecords.data {
            fileWrapper = FileWrapper(regularFileWithContents: JSON_DATA)
        }
        
        return fileWrapper
    } */
    
    func fileWrapper(snapshot: [Record], configuration: WriteConfiguration) throws -> FileWrapper {
        var fileWrappr = FileWrapper()
        
        if let JSON_Data = snapshot.data {
            fileWrappr = FileWrapper(regularFileWithContents: JSON_Data)
        }
        
        return fileWrappr
    }
    
    func snapshot(contentType: UTType) throws -> [Record] {
        return self.records.sortedRecords
    }
}
