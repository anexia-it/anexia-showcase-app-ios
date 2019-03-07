//
//  PushLinkViewController.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

/// The view controller controls the lifecycle of views and holds also all views.
/// In the MVVM pattern the view controller is the representation of the general "View".
class PushLinkViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    private let log = Logger()
    var viewModel: PushLinkViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)
        setupBindings()
        viewModel.viewDidLoad()
    }
    
    private func setupBindings() {
        self.viewModel.viewBinding.timeoutAlert = { [weak self] in
            self?.timeoutAlert()
        }
        
        self.viewModel.viewBinding.updateProgress = { [weak self] progress in
            self?.progressView.progress = progress
        }
    }
    
    func timeoutAlert() {
        let alertController = UIAlertController(title: "Timeout", message: "Connection cannot be established.", preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Continue searching", style: .default) { (action) in
            // No-op
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        log.info("")
    }
}
