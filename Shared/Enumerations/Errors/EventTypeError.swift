//
//  EventTypeError.swift
//  Checkbook
//
//  Created by Bryce Campbell on 5/27/21.
//

import Foundation

enum EventTypeError: LocalizedError {
    case invalidType
    
    var errorDescription: String? {
        var error: String? = nil
        
        switch self {
        case .invalidType: error = "Specified type is not valid."
        }
        
        return error
    }
}
