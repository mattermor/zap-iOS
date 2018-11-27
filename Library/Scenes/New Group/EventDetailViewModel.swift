//
//  Library
//
//  Created by Otto Suess on 17.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC

protocol EventDetailViewModelDelegate: class {
    func openBlockExplorer(code: String, type: BlockExplorer.CodeType)
}

final class EventDetailViewModel {
    private let event: HistoryEventType
    
    init(event: HistoryEventType) {
        self.event = event
    }
    
    func detailConfiguration(delegate: EventDetailViewModelDelegate) -> [StackViewElement] {
        var result = [StackViewElement]()
        
        switch event {
        case .transactionEvent(let event):
            result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.transactionDetail))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.amountLabel, amount: event.amount))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.feeLabel, amount: event.fee, skipZero: true))
            result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.memoLabel, content: event.memo))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))
            result.append(contentsOf: blockExplorerButton(title: L10n.Scene.TransactionDetail.transactionIdLabel, code: event.txHash, type: .transactionId, delegate: delegate))
            result.append(contentsOf: blockExplorerButton(title: L10n.Scene.TransactionDetail.addressLabel, code: event.destinationAddresses.first?.string, type: .address, delegate: delegate))
            
        case .channelEvent(let event):
            result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.channelEventDetail))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.feeLabel, amount: event.channelEvent.fee, skipZero: true))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))
            result.append(contentsOf: blockExplorerButton(title: L10n.Scene.TransactionDetail.transactionIdLabel, code: event.channelEvent.txHash, type: .transactionId, delegate: delegate))
            
        case .createInvoiceEvent(let event):
            result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.lightningInvoice))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.amountLabel, amount: event.amount))
            result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.memoLabel, content: event.memo))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.expiryLabel, date: event.expiry))
            
        case .failedPaymentEvent(let event):
            result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.failedPayment))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.amountLabel, amount: event.amount))
            result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.memoLabel, content: event.memo))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))
            
        case .lightningPaymentEvent(let event):
            result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.paymentDetail))
            result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.memoLabel, content: event.memo))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.amountLabel, amount: event.amount))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.feeLabel, amount: event.fee))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))
        }
        
        return result
    }
    
    func headline(_ headline: String) -> [StackViewElement] {
        return [
            .label(text: headline, style: Style.Label.headline.with({ $0.textAlignment = .center })),
            .separator
        ]
    }
    
    private func label(title: String, element: StackViewElement) -> [StackViewElement] {
        return [
            .horizontalStackView(compressionResistant: .first, content: [
                .label(text: title, style: Style.Label.headline),
                element
            ])
        ]
    }
    
    private func label(title: String, content: String?) -> [StackViewElement] {
        guard let content = content else { return [] }
        return label(title: title, element: .label(text: content, style: Style.Label.body))
    }
    
    private func amountLabel(title: String, amount: Satoshi?, skipZero: Bool = false) -> [StackViewElement] {
        guard
            let amount = amount,
            !skipZero || amount != 0
            else { return [] }
        return label(title: title, element: .amountLabel(amount: amount, style: Style.Label.body))
    }
    
    private func dateLabel(title: String, date: Date) -> [StackViewElement] {
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
        return label(title: title, content: dateString)
    }
    
    private func blockExplorerButton(title: String, code: String?, type: BlockExplorer.CodeType, delegate: EventDetailViewModelDelegate?) -> [StackViewElement] {
        guard let code = code else { return [] }
        return label(title: title, element: .button(title: code, style: Style.Button.custom(), completion: { _ in
            delegate?.openBlockExplorer(code: code, type: type)
        }))
    }
}