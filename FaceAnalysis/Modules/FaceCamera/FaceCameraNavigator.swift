//
//  FaceCameraNavigator.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

protocol FaceCameraNavigatorProtocol {
    func navigateToBridgeConnectionView()
}

/// Controls the navigation from one view to the other.
/// The Navigator is also needed as transport for the dependency container.
class FaceCameraNavigator {
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

extension FaceCameraNavigator: FaceCameraNavigatorProtocol {
    /// Navigates to the BridgeConnection view
    func navigateToBridgeConnectionView() {
        let builder = BridgeConnectionBuilder(dependencyContainer: self.dependencyContainer)
        let view = builder.build()
        let nc = UINavigationController(rootViewController: view)
        self.navigatable?.present(nc, animated: true, completion: nil)
    }
}
