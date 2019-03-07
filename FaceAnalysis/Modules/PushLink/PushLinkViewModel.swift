//
//  PushLinkViewModel.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

protocol PushLinkViewModelProtocol {
    var viewBinding: PushLinkViewModelBinding { get }
    
    func viewDidLoad()
}

/// All view bindings used in the current view model.
class PushLinkViewModelBinding {
    var timeoutAlert: (() -> ())?
    var updateProgress: ((Float) -> ())?
}

/// The view model controls all presentation logic.
/// The view model does not has a reference to the view itself,
/// but indicated view changes over bindings.
class PushLinkViewModel {
    private let log = Logger()
    var viewBinding = PushLinkViewModelBinding()
    
    deinit {
        log.info("")
    }
}

extension PushLinkViewModel: PushLinkViewModelProtocol {
    
    /// Starts a timer which after expiration triggers an alert in the view.
    func viewDidLoad() {
        let timeout: Float = 30
        var timeLeft = timeout
        self.viewBinding.updateProgress?(1.0)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            timeLeft -= 1
            let progress = timeLeft / timeout
            self?.viewBinding.updateProgress?(progress)
           
            if timeLeft == 0 {
                self?.viewBinding.timeoutAlert?()
                timer.invalidate()
            }
        }
    }
}
