//
//  BridgeConnectionBuilder.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

/// Builds a module and injects all needed dependencies in each submodule
class BridgeConnectionBuilder {
    private let log = Logger()
    private let dependencyContainer: DependencyContainerProtocol
    
    init(dependencyContainer: DependencyContainerProtocol) {
        self.dependencyContainer = dependencyContainer
    }
    
    func build() -> UIViewController {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BridgeConnectionViewController") as! BridgeConnectionViewController
        let navigator = BridgeConnectionNavigator(navigatable: view, dependencyContainer: self.dependencyContainer)
        let viewModel = BridgeConnectionViewModel(navigator: navigator, philipsHueService: dependencyContainer.philipsHueService)
        view.viewModel = viewModel
        return view
    }
    
    deinit {
        log.info("")
    }
}
