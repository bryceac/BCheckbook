//
//  OptionalComparator.swift
//  BCheckbook (macOS)
//
//  Created by Bryce Campbell on 7/16/22.
//

import Foundation

struct OptionalComparator<T>: SortComparator {
    typealias Compared = T?
    
    var order: SortOrder = .forward
    
    func compare(_ lhs: T?, _ rhs: T?) -> ComparisonResult {
        switch (lhs, rhs) {
        case (.none, .some(_)): return order == .forward ? .orderedDescending : .orderedAscending
        case (.some(_), .none): return order == .forward ? .orderedAscending : .orderedDescending
        default: return .orderedSame
        }
    }
}
