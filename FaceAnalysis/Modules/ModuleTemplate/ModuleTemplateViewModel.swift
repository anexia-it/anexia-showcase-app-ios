//
//  ModuleTemplateViewModel.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

protocol ModuleTemplateViewModelProtocol {
    
}

/// All view bindings used in the current view model.
class ModuleTemplateViewModelBindings {
    
}

/// The view model controls all presentation logic.
/// The view model does not has a reference to the view itself,
/// but indicated view changes over bindings.
class ModuleTemplateViewModel {
    private let log = Logger()
    private let navigator: ModuleTemplateNavigatorProtocol
    
    init(navigator: ModuleTemplateNavigatorProtocol) {
        self.navigator = navigator
    }
    
    deinit {
        log.info("")
    }
}

// MARK: - ModuleTemplateViewModelProtocol
extension ModuleTemplateViewModel: ModuleTemplateViewModelProtocol {
    
}
