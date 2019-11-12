//
//  Library
//
//  Created by 0 on 08.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import Logger

final class LNURLWithdrawQRCodeScannetStrategy: QRCodeScannerStrategy {
    let title = "Withdraw"
    let pasteButtonTitle = "Paste LNURL Withdraw"
    
    let lightningService: LightningService
    
    init(lightningService: LightningService) {
        self.lightningService = lightningService
    }
    
    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController, QRCodeScannerStrategyError>) -> Void) {
        LNURL.parse(string: address) { [lightningService] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lnurl):
                    switch lnurl {
                    case .withdraw(let request):
                        let viewModel = LNURLWithdrawViewModel(request: request, lightningService: lightningService)
                        let viewController = LNURLWithdrawViewController.instantiate(viewModel: viewModel)
                        completion(.success(ZapNavigationController(rootViewController: viewController)))
                    }
                case .failure(let error):
                    Logger.error(error)
                    switch error {
                    case .statusError(let message):
                        completion(.failure(QRCodeScannerStrategyError(message: message)))
                    case .urlError(let error):
                        completion(.failure(QRCodeScannerStrategyError(message: error.localizedDescription)))
                    case .invalidBech32, .jsonError, .unknownError, .unsupported:
                        completion(.failure(QRCodeScannerStrategyError(message: L10n.Scene.QrcodeScanner.Error.unknownFormat)))
                    }
                }
            }
        }
    }
}