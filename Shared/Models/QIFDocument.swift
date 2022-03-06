//
//  BCheckFile.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/8/21.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import QIF

extension UTType {
    static var quickenInterchangeFormat: UTType {
        UTType(importedAs: "me.brycecampbell.qif")
    }
}

class QIFDocument: ReferenceFileDocument {
    
    
    static var readableContentTypes: [UTType] = [.bcheckFiles]
    
    var records: Records = Records()
    
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
    
    func fileWrapper(snapshot: [Record], configuration: WriteConfiguration) throws -> FileWrapper {
        
        var fileWrapper = FileWrapper()
        
        if let qif = try? generateQIF(), let qifData = "\(qif)".data(using: .utf8) {
            fileWrapper = FileWrapper(regularFileWithContents: qifData)
        }
        
        return fileWrapper
    }
    
    func generateQIF() throws -> QIF {
        let qifTransactions = records.sortedRecords.map { record in
            QIFTransaction(record.event)
        }
        
        let sectionText = qifTransactions.reduce(into: "!Type:Bank\n") { string, transaction in
            string += "\(transaction)\n\n"
        }.replacingOccurrences(of: "\n", with: "\r\n")
        
        return try QIF(sectionText)
    }
    
    func snapshot(contentType: UTType) throws -> [Record] {
        return records.sortedRecords
    }
}
