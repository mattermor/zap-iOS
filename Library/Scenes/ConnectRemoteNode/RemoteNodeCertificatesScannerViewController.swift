//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateRemoteNodeCertificatesScannerViewController(connectRemoteNodeViewModel: ConnectRemoteNodeViewModel) -> RemoteNodeCertificatesScannerViewController {
        let viewController = Storyboard.connectRemoteNode.instantiate(viewController: RemoteNodeCertificatesScannerViewController.self)
        viewController.connectRemoteNodeViewModel = connectRemoteNodeViewModel
        return viewController
    }
}

// swiftlint:disable:next type_name
final class RemoteNodeCertificatesScannerViewController: UIViewController {
    @IBOutlet private weak var navigationBar: UINavigationBar!
    
    fileprivate var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.handler = { [weak self] code in
                if let remoteNodeConfigurationQRCode = RemoteNodeConfigurationQRCode(json: code) {
                    self?.scannerView.stop()
                    self?.connectRemoteNodeViewModel?.updateQRCode(remoteNodeConfigurationQRCode)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}