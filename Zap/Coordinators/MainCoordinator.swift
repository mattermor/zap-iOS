//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SafariServices
import UIKit

final class MainCoordinator {
    private let rootViewController: RootViewController
    private let lightningService: LightningService
    private let channelListViewModel: ChannelListViewModel
    private let transactionListViewModel: TransactionListViewModel
    
    private weak var mainViewController: MainViewController?
    private weak var detailViewController: UINavigationController?
    
    init(rootViewController: RootViewController, viewModel: LightningService) {
        self.rootViewController = rootViewController
        self.lightningService = viewModel
        
        channelListViewModel = ChannelListViewModel(viewModel: viewModel)
        transactionListViewModel = TransactionListViewModel(viewModel: viewModel)
    }
    
    func start() {
        let viewController = UIStoryboard.instantiateMainViewController(with: lightningService, settingsButtonTapped: presentSettings, sendButtonTapped: presentSend, requestButtonTapped: presentRequest, transactionsButtonTapped: presentTransactions, networkButtonTapped: presentNetwork)
        self.mainViewController = viewController
        DispatchQueue.main.async {
            self.rootViewController.setContainerContent(viewController)
            self.presentTransactions()
        }
    }
    
    private func presentSettings() {
        let viewController = UIStoryboard.instantiateSettingsContainerViewController(with: lightningService)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentTransactions() {
        let viewController = UIStoryboard.instantiateTransactionListViewController(with: lightningService, transactionListViewModel: transactionListViewModel, presentTransactionDetail: presentTransactionDetail)
        mainViewController?.setContainerContent(viewController)
    }
    
    private func presentNetwork() {
        let viewController = UIStoryboard.instantiateChannelListViewController(with: lightningService, channelListViewModel: channelListViewModel, presentChannelDetail: presentChannelDetail, addChannelButtonTapped: presentAddChannel)
        mainViewController?.setContainerContent(viewController)
    }
    
    func presentSend() {
        presentSend(invoice: nil)
    }
    
    func presentSend(invoice: String?) {
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: lightningService, strategy: SendQRCodeScannerStrategy())
        mainViewController?.present(viewController, animated: true) {
            if let invoice = invoice,
                let qrCodeScannerViewController = viewController.topViewController as? QRCodeScannerViewController {
                qrCodeScannerViewController.displayViewControllerForAddress(type: .lightningInvoice, address: invoice)
            }
        }
    }
    
    func presentRequest() {
        let viewController = UIStoryboard.instantiateRequestViewController(with: lightningService)
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentAddChannel() {
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: lightningService, strategy: OpenChannelQRCodeScannerStrategy())
        mainViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentChannelDetail(for channelViewModel: ChannelViewModel) {
        let detailViewModel = ChannelDetailViewModel(channel: channelViewModel.channel, lightningService: lightningService)
        presentDetail(for: detailViewModel)
    }
    
    private func presentTransactionDetail(for transactionViewModel: TransactionViewModel) {
        presentDetail(for: DetailViewModelFactory.instantiate(from: transactionViewModel, lightningService: lightningService))
    }
    
    private func presentDetail(for detailViewModel: DetailViewModel) {
        let detailViewController = UIStoryboard.instantiateDetailViewController(detailViewModel: detailViewModel, dismissButtonTapped: dismissDetailViewController, safariButtonTapped: presentSafariViewController)
        self.detailViewController = detailViewController
        mainViewController?.present(detailViewController, animated: true, completion: nil)
    }
    
    private func presentSafariViewController(for url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.zap.peach
        detailViewController?.present(safariViewController, animated: true)
    }
    
    private func dismissDetailViewController() {
        detailViewController?.dismiss(animated: true, completion: nil)
    }
}