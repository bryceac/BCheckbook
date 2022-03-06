//
//  QIFTransaction+fromEvent.swift
//  BCheckbook
//
//  Created by Bryce Campbell on 3/5/22.
//

import Foundation
import QIF

extension QIFTransaction {
    init(_ transaction: Event) {
        self.init(date: transaction.date, checkNumber: transaction.checkNumber, vendor: transaction.vendor, address: transaction.vendor, amount: EventType.withdrawal ~= transaction.type ? transaction.amount * -1 : transaction.amount, category: transaction.category, memo: transaction.memo, status: transaction.isReconciled ? TransactionStatus.reconciled : nil)
    }
}
