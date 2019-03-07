//
//  BridgeConnectionViewModel.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

protocol BridgeConnectionViewModelProtocol {
    var lastConnectedBridge: PHBridgeInfo? { get }
    var bridge: PHSBridge? { get }
    var selectedBridge: PHBridgeInfo? { get }
    var numberOfRows: Int { get }
    var viewBinding: BridgeConnectionViewModelBinding { get }
    
    func autoConnectBridge()
    func anexiaDefaultLightsAction()
    func close()
    func viewDidAppear()
    func refresh()
    func switchValueChanged(isOn: Bool, index: Int)
    func cellViewModelFor(indexPath: IndexPath) -> BridgeSelectionTableViewCellViewModelProtocol?
}


/// All view bindings used in the current view model.
class BridgeConnectionViewModelBinding {
    var showAlertView: (() -> ())?
    var reload: (() -> ())?
    var indicateLoading: ((_ enabled: Bool) -> ())?
}

/// The view model controls all presentation logic.
/// The view model does not has a reference to the view itself,
/// but indicated view changes over bindings.
class BridgeConnectionViewModel {
    private let log = Logger()
    private let navigator: BridgeConnectionNavigatorProtocol
    private var philipsHueService: PhilipsHueServiceProtocol
    private var isDiscovering = false
    private var bridges = [PHBridgeInfo]()
    private var bridgeRetryCount = 0
    let viewBinding = BridgeConnectionViewModelBinding()

    init(navigator: BridgeConnectionNavigatorProtocol,
         philipsHueService: PhilipsHueServiceProtocol) {
        self.navigator = navigator
        self.philipsHueService = philipsHueService
        self.setupBindings()
    }
    
    
    /// Setup bindings to other services
    private func setupBindings() {
        self.philipsHueService.authenticated = { [weak self] in
            self?.navigator.dismiss()
        }
        self.philipsHueService.notAuthenticated = { [weak self] in
            self?.navigator.navigateToPushLinkView()
        }
    }
    
    
    /// Discover bridges in the current network
    private func discoverBridges() {
        let options: PHSBridgeDiscoveryOption = PHSBridgeDiscoveryOption(arrayLiteral: [.discoveryOptionIPScan,.discoveryOptionNUPNP,.discoveryOptionUPNP])
        let bridgeDiscovery = PHSBridgeDiscovery()
        
        if !self.isDiscovering {
            self.isDiscovering = true
            self.viewBinding.indicateLoading?(true)
        }
        
        bridgeDiscovery.search(options) { (result, returnCode) in
            if returnCode == .success {
                
                self.bridges.removeAll()
                
                if let result = result {
                    for (_, value) in result {
                        let bridgeInfo = PHBridgeInfo(ipAddress: value.ipAddress, uniqueID: value.uniqueId)
                        self.bridges.append(bridgeInfo)
                    }
                    self.viewBinding.reload?()
                }
                if self.bridges.count == 0 && self.bridgeRetryCount != 20 {
                    self.bridgeRetryCount += 1
                    self.discoverBridges()
                } else {
                    self.viewBinding.indicateLoading?(false)
                    self.isDiscovering = false
                    if self.bridges.count == 0 && self.lastConnectedBridge == nil {
                        self.viewBinding.showAlertView?()
                    }
                }
            } else {
                self.log.info(returnCode)
            }
        }
    }
    
    deinit {
        log.info("")
    }
}

// MARK: - BridgeConnectionViewModelProtocol
extension BridgeConnectionViewModel: BridgeConnectionViewModelProtocol {
    var lastConnectedBridge: PHBridgeInfo? {
        return self.philipsHueService.lastConnectedBridge
    }
    
    var selectedBridge: PHBridgeInfo? {
        get {
            return self.philipsHueService.selectedBridge
        }
        
        set {
            self.philipsHueService.selectedBridge = newValue
        }
    }
    
    var bridge: PHSBridge? {
        return self.philipsHueService.bridge
    }
    
    var numberOfRows: Int {
        return self.bridges.count
    }
    
    func close() {
        self.navigator.dismiss()
    }
    
    func autoConnectBridge() {
        self.philipsHueService.autoConnectBridge()
    }
    
    func anexiaDefaultLightsAction() {
        self.philipsHueService.anexiaDefaultLightsAction()
    }
    
    func viewDidAppear() {
        discoverBridges()
        if let last = self.lastConnectedBridge {
            bridges.removeAll()
            bridges.append(last)
        }
        
        if bridges.count > 0 {
            self.viewBinding.reload?()
        }
    }
    
    func refresh() {
        if !isDiscovering {
            self.discoverBridges()
        }
    }
    
    
    /// Reacts on Switch value changed events
    ///
    /// - Parameters:
    ///   - isOn: indicates if the swicht is on or off
    ///   - index: The indix of the bridge with the switch
    @objc func switchValueChanged(isOn: Bool, index: Int) {
        guard bridges.indices.contains(index) else { return }
        self.selectedBridge = bridges[index]

        if isOn {
            self.autoConnectBridge()
        }
        else {
            self.anexiaDefaultLightsAction()
            
            if self.selectedBridge?.ipAddress == self.lastConnectedBridge?.ipAddress &&
                self.selectedBridge?.uniqueID == self.lastConnectedBridge?.uniqueID {
                
                if let lastConnectedBridge = self.lastConnectedBridge {
                    PHSKnownBridges.forgetBridge(lastConnectedBridge.uniqueID)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.bridge?.disconnect()
                }
                self.selectedBridge = nil
            }
        }
        self.viewBinding.reload?()
    }
    
    
    /// Create a cell view model
    ///
    /// - Parameter indexPath: the index path
    /// - Returns: the cell view model
    func cellViewModelFor(indexPath: IndexPath) -> BridgeSelectionTableViewCellViewModelProtocol? {
        guard bridges.indices.contains(indexPath.row) else { return nil }
        guard let lastBridge = self.lastConnectedBridge else { return nil }
        let bridge = bridges[indexPath.row]
        let viewModel = BridgeSelectionTableViewCellViewModel(bridge: bridge,
                                                              lastConnectedBridge: lastBridge,
                                                              selector: #selector(self.switchValueChanged(isOn:index:)),
                                                              selectorTarget: self,
                                                              indexPath: indexPath)
        return viewModel
    }
}
