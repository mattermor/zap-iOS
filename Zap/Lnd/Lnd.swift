//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import LightningRpc
import Lndbindings

let shoudConnectToRemoteLnd = true

final class Lnd {
    static let instance = Lnd()
    private let strategy: ConnectionStrategy
    
    var lightning: LightningRpc.Lightning?
    var walletUnlocker: LightningRpc.WalletUnlocker?
    
    private init() {
        if shoudConnectToRemoteLnd {
            strategy = RemoteConnection()
        } else {
            strategy = LocalConnection()
        }
    }
    
    var macaroon: String? {
        return strategy.macaroon
    }
    
    func connect() {
        let cert = strategy.cert
        let host = strategy.host
    
        try? GRPCCall.setTLSPEMRootCerts(cert, forHost: host)
            
        lightning = LightningRpc.Lightning(host: host)
        walletUnlocker = LightningRpc.WalletUnlocker(host: host)
    }
    
    func startLnd() {
        strategy.startLnd()
        connect()
    }
    
    func stopLnd() {
        strategy.stopLnd(lightning)
    }
}

private protocol ConnectionStrategy {
    var host: String { get }
    
    var cert: String? { get }
    var macaroon: String? { get }
    
    func startLnd()
    func stopLnd(_ lightning: LightningRpc.Lightning?)
}

private final class LocalConnection: ConnectionStrategy {
    var lndPath: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { fatalError("lnd path not found") }
        return url
    }
    
    private var certPath: URL {
        return lndPath.appendingPathComponent("tls.cert")
    }
    
    let host = "127.0.0.1:10009"

    var cert: String? {
        return try? String(contentsOf: certPath, encoding: .utf8)
    }
    
    private var cachedMacaroon: String?
    var macaroon: String? {
        if cachedMacaroon != nil {
            return cachedMacaroon
        }
        
        let macaroonPath = lndPath.appendingPathComponent("admin.macaroon")
        guard FileManager.default.fileExists(atPath: macaroonPath.path) else { return nil }
        cachedMacaroon = try? Data(contentsOf: macaroonPath).hexString()
        return cachedMacaroon
    }
    
    init() {
        setupConfigurationFile()
    }
    
    func startLnd() {
        guard ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] != "1" else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            LndbindingsStart(self.lndPath.path)
        }
        
        while !FileManager.default.fileExists(atPath: certPath.path) {
            print(Date(), "😴 Waiting for certs to be created.")
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    func stopLnd(_ lightning: LightningRpc.Lightning?) {
        lightning?.stopDaemon(with: StopRequest()) { _, error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func setupConfigurationFile() {
        LndConfiguration.standard.save(at: lndPath)
    }
}

private final class RemoteConnection: ConnectionStrategy {
    let host = "lnd3.ddns.net:10011"
    
    var cert: String? {
        return RemoteLndConfiguration.cert
    }
    
    var macaroon: String? {
        return RemoteLndConfiguration.macaroon
    }
    
    func startLnd() {}
    func stopLnd(_ lightning: LightningRpc.Lightning?) {}
}
