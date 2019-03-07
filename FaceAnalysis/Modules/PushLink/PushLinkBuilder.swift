//
//  PushLinkBuilder.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

/// Builds a module and injects all needed dependencies in each submodule
class PushLinkBuilder {
    private let log = Logger()
    private let dependencyContainer: DependencyContainerProtocol
    
    init(dependencyContainer: DependencyContainerProtocol) {
        self.dependencyContainer = dependencyContainer
    }
    
    func build() -> UIViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let view = sb.instantiateViewController(withIdentifier: "PushLinkViewController") as! PushLinkViewController
        let viewModel = PushLinkViewModel()
        view.viewModel = viewModel
        return view
    }
    
    deinit {
        log.info("")
    }
}
