//
//  ModuleTemplateViewController.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

/// The view controller controls the lifecycle of views and holds also all views.
/// In the MVVM pattern the view controller is the representation of the general "View".
class ModuleTemplateViewController: UIViewController {
    
    private let log = Logger()
    var viewModel: ModuleTemplateViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)
        self.setupUI()
    }
    
    private func setupUI() {
        
    }
    
    deinit {
        log.info("")
    }
}
