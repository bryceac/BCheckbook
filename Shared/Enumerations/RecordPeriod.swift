//
//  SummaryPeriod.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 1/9/22.
//

import Foundation

enum RecordPeriod: String, CaseIterable {
    case all, week, month, threeMonths = "3 mos", sixMonths = "6 mos", year
}
