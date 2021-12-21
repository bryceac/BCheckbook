//
//  DB.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 12/17/21.
//

import Foundation

class DB {
    var manager: DBManager?
    var url: URL {
        didSet {
            manager = try? DBManager(withDB: url)
        }
    }
    
    static let shared = DB()
    
    private init() {
        
        #if os(iOS)
        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        url = DOCUMENTS_DIRECTORY.appendingPathComponent("register").appendingPathExtension("db")
        
        if !FileManager.default.fileExists(atPath: url.absoluteString), let BUNDLE_PATH = Bundle.main.url(forResource: url.deletingPathExtension().lastPathComponent, withExtension: url.pathExtension) {
            try? FileManager.default.copyItem(at: BUNDLE_PATH, to: url)
        }
        #else
        let APPLICATION_SUPPORT_DIRECTORY = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        
        url = APPLICATION_SUPPORT_DIRECTORY.appendingPathComponent("register").appendingPathExtension("db")
        
        if !FileManager.default.fileExists(atPath: url.absoluteString), let BUNDLE_PATH = Bundle.main.url(forResource: url.deletingPathExtension().lastPathComponent, withExtension: url.pathExtension) {
            try? FileManager.default.copyItem(at: BUNDLE_PATH, to: url)
        }
        #endif
        
        manager = try? DBManager(withDB: url)
    }
}
