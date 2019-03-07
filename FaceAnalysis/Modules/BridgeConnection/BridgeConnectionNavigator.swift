//
//  BridgeConnectionNavigator.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

protocol BridgeConnectionNavigatorProtocol {
    func dismiss()
    func navigateToPushLinkView()
}

/// Controls the navigation from one view to the other.
/// The Navigator is also needed as transport for the dependency container.
class BridgeConnectionNavigator {
    private let log = Logger()
    private weak var navigatable: Navigatable?
    private let dependencyContainer: DependencyContainerProtocol
    
    init(navigatable: Navigatable, dependencyContainer: DependencyContainerProtocol) {
        self.navigatable = navigatable
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        log.info("")
    }
}

extension BridgeConnectionNavigator: BridgeConnectionNavigatorProtocol {
    func dismiss() {
        self.navigatable?.dismiss(animated: true, completion: nil)
    }
    
    func navigateToPushLinkView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let pushLinkVC = storyboard.instantiateViewController(withIdentifier: "PushLinkViewController") as? PushLinkViewController {
            if let topController = UIApplication.topViewController() {
                topController.present(pushLinkVC, animated: true, completion: nil)
            }
        }
    }
}
