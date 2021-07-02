//
//  Bundle+displayName.swift
//  Checkbook
//
//  Created by Bryce Campbell on 7/2/21.
//

import Foundation

extension Bundle {
    var displayName: String? {
        return Bundle.main.infoDictionary?["Bundle name"] as? String
    }
}
