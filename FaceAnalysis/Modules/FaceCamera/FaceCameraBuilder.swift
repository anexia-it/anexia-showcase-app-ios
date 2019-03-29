//
//  FaceCameraBuilder.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

/// Builds a module and injects all needed dependencies in each submodule
class FaceCameraBuilder {
    private let log = Logger()
    private let dependencyContainer: DependencyContainerProtocol
    
    init(dependencyContainer: DependencyContainerProtocol) {
        self.dependencyContainer = dependencyContainer
    }
    
    func build() -> UIViewController {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! FaceCameraViewController
        let navigator = FaceCameraNavigator(navigatable: view, dependencyContainer: self.dependencyContainer)
        let viewModel = FaceCameraViewModel(navigator: navigator,
                                            imageCaptureService: ImageCaptureService(),
                                            philipsHueService: dependencyContainer.philipsHueService,
                                            faceAnalysisService: dependencyContainer.faceAnalysisService,
                                            imageUploadService: dependencyContainer.imageUploadService)
        view.viewModel = viewModel
        return view
    }
    
    deinit {
        log.info("")
    }
}
