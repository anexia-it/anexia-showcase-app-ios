//
//  ModuleTemplateNavigator.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

protocol ModuleTemplateNavigatorProtocol {
    
}

/// Controls the navigation from one view to the other.
/// The Navigator is also needed as transport for the dependency container.
class ModuleTemplateNavigator {
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

extension ModuleTemplateNavigator: ModuleTemplateNavigatorProtocol {
    
}
