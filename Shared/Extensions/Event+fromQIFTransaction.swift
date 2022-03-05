//
//  Event+fromQIFTransaction.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 3/5/22.
//

import Foundation
import QIF

extension Event {
    init(_ transaction: QIFTransaction) {
        self.init(date: transaction.date, checkNumber: transaction.checkNumber != nil && transaction.checkNumber! > 0 ? transaction.checkNumber : nil, category: transaction.category != nil && !(transaction.category!.isEmpty) ? transaction.category : nil, vendor: transaction.vendor, memo: transaction.memo, amount: transaction.amount, andIsReconciled: TransactionStatus.reconciled ~= transaction.status)
    }
}
