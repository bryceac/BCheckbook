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
        let transactionText = """
        D\(QIFTransaction.QIF_DATE_FORMATTER.string(from: transaction.date))
        T\(EventType.withdrawal ~= transaction.type ? transaction.amount * -1 : transaction.amount)
        C\(transaction.isReconciled ? TransactionStatus.reconciled.rawValue : "")
        N\(transaction.checkNumber ?? 0)
        P\(transaction.vendor)
        M\(transaction.memo)
        A\(transaction.vendor)
        L\(transaction.category ?? "")
        ^
        """
        
        try! self.init(transactionText)
    }
}
