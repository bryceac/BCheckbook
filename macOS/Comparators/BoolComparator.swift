//
//  BoolComparator.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/16/22.
//

import Foundation

struct BoolComparator: SortComparator {
    func compare(_ lhs: Bool, _ rhs: Bool) -> ComparisonResult {
        switch (lhs, rhs) {
        case (true, false): return order == .forward ? .orderedDescending : .orderedAscending
        case (false, true): return order == .forward ? .orderedAscending : .orderedDescending
        default: return .orderedSame
        }
    }
    
    var order: SortOrder = .forward
    
    typealias Compared = Bool
}
