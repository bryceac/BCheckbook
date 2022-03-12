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
import SQLite

extension UTType {
    static var bcheckFiles: UTType {
        UTType(importedAs: "me.brycecampbell.bcheck")
    }
    
    static var quickenInterchangeFormat: UTType {
        UTType(importedAs: "me.brycecampbell.qif")
    }
}

class BCheckFileDocument: ReferenceFileDocument {
    
    
    static var readableContentTypes: [UTType] = [.bcheckFiles, .quickenInterchangeFormat]
    
    var records: Records = Records()
    
    init(records: Records = Records()) {
        self.records = records
    }
    
    required convenience init(configuration: ReadConfiguration) throws {
        var records = Records()
        
        if let fileData = configuration.file.regularFileContents {
            
            if let fileName = configuration.file.filename, fileName.hasSuffix(".bcheck") {
                let SAVED_RECORDS = try Record.load(from: fileData)
                
                records = Records(withRecords: SAVED_RECORDS)
            } else if let content = String(data: fileData, encoding: .utf8) {
                let qif = try QIF(content)
                
                if let bank = qif.sections[QIFType.bank.rawValue] {
                    let SAVED_RECORDS = bank.transactions.map { transaction in
                        Record(transaction: Event(transaction))
                    }
                    
                    records = Records(withRecords: SAVED_RECORDS)
                }
            }
        }
        
        self.init(records: records)
    }
    
    func generateQIF() -> QIF {
        let qifTransactions = records.sortedRecords.map { record in
            QIFTransaction(record.event)
        }
        
        let section = QIFSection(type: .bank, transactions: Set(qifTransactions))
        
        return QIF(sections: [section.type.rawValue: section])
    }
    
    func fileWrapper(snapshot: [Record], configuration: WriteConfiguration) throws -> FileWrapper {
        
        var fileWrapper = FileWrapper()
        
        if configuration.contentType == UTType.bcheckFiles {
            if let JSON_DATA = records.sortedRecords.data {
                fileWrapper = FileWrapper(regularFileWithContents: JSON_DATA)
            }
        } else {
            let qif = generateQIF()
            
            if let qifData = "\(qif)".data(using: .utf8) {
                fileWrapper = FileWrapper(regularFileWithContents: qifData)
            }
        }
        
        return fileWrapper
    }
    
    func snapshot(contentType: UTType) throws -> [Record] {
        return records.sortedRecords
    }
}
