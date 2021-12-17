//
//  DB.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 12/17/21.
//

import Foundation

class DB {
    var manager: DBManager?
    var url: URL
    
    static let shared = DB()
    
    private init() {
        let DOCUMENTS_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        url = DOCUMENTS_DIRECTORY.appendingPathComponent("register").appendingPathExtension("db")
        
        manager = try? DBManager(withDB: url)
    }
}
