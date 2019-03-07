//
//  BridgeSelectionTableViewCellViewModel.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 01.03.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

protocol BridgeSelectionTableViewCellViewModelProtocol {
    var text: String { get }
    var detailText: String { get }
    var switchTag: Int { get }
    var selectorTarget: Any { get }
    var selector: Selector { get }
    var switchViewIsOn: Bool { get }
}

class BridgeSelectionTableViewCellViewModel {
    private let bridge: PHBridgeInfo
    private let lastConnectedBridge: PHBridgeInfo
    private let selectorInternal: Selector
    private let indexPath: IndexPath
    private let selectorTargetInternal: Any
    
    init(bridge: PHBridgeInfo,
         lastConnectedBridge: PHBridgeInfo,
         selector: Selector,
         selectorTarget: Any,
         indexPath: IndexPath) {
        self.bridge = bridge
        self.lastConnectedBridge = lastConnectedBridge
        self.selectorInternal = selector
        self.selectorTargetInternal = selectorTarget
        self.indexPath = indexPath
    }
}

extension BridgeSelectionTableViewCellViewModel: BridgeSelectionTableViewCellViewModelProtocol {
    var text: String {
        return self.bridge.ipAddress
    }
    
    var detailText: String {
        return self.bridge.uniqueID
    }
    
    var switchTag: Int {
        return self.indexPath.row
    }
    
    var selectorTarget: Any {
        return self.selectorTargetInternal
    }
    
    var selector: Selector {
        return self.selectorInternal
    }
    
    var switchViewIsOn: Bool {
        if bridge.ipAddress == self.lastConnectedBridge.ipAddress &&
            bridge.uniqueID == self.lastConnectedBridge.uniqueID {
            return true
        }
        return false
    }
}
