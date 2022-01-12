//
//  SummaryPeriod.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 1/9/22.
//

import Foundation

enum RecordPeriod: String, CaseIterable {
    case all, week, month = "mth", threeMonths = "qtr", sixMonths = "hy", year
}
