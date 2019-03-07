//
//  FaceCameraViewModel.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol FaceCameraViewModelProtocol {
    var lastImage: UIImage? { get }
    var capturedImage: UIImage? { get }
    var viewBinding: FaceCameraViewModelBinding { get }
    
    func viewDidAppear()
    func captureButtonTapped()
    func removeOverlays()
    func viewDidLoad()
    func setup()
    func switchCamera()
    func upload(image: UIImage?)
    func retakeButtonClicked()
    func philipsHueButtonTapped()
}

class FaceCameraViewModelBinding {
    var showPermissionAlert: (() -> ())?
    var setupCameraView: ((AVCaptureVideoPreviewLayer) -> ())?
    var preparePhotoCapturedUI: (() -> ())?
    var preparePhotoRetakeUI: (() -> ())?
    var showMessage: ((String) -> ())?
    var enableActivityIndicator: ((Bool) -> ())?
    var hideActivityIndicator: ((Bool) -> ())?
    var flipCameraView: (() -> ())?
    var share: ((URL) -> ())?
    var drawOverlays: (([String]) -> ())?
}

/// The view model controls all presentation logic.
/// The view model does not has a reference to the view itself,
/// but indicated view changes over bindings.
class FaceCameraViewModel: FaceCameraViewModelProtocol {
    private let log = Logger()
    private let navigator: FaceCameraNavigatorProtocol
    private let imageCaptureService: ImageCaptureServiceProtocol
    private let philipsHueService: PhilipsHueServiceProtocol
    private let faceAnalysisService: FaceAnalysisServiceProtocol
    private let imageUploadService: ImageUploadServiceProtocol
    private var isPhotoCaptured = false
    private(set) var capturedImage: UIImage?
    let viewBinding = FaceCameraViewModelBinding()
    
    init(navigator: FaceCameraNavigatorProtocol,
         imageCaptureService: ImageCaptureServiceProtocol,
         philipsHueService: PhilipsHueServiceProtocol,
         faceAnalysisService: FaceAnalysisServiceProtocol,
         imageUploadService: ImageUploadServiceProtocol) {
        self.navigator = navigator
        self.imageCaptureService = imageCaptureService
        self.philipsHueService = philipsHueService
        self.faceAnalysisService = faceAnalysisService
        self.imageUploadService = imageUploadService
        NotificationCenter.default.addObserver(self, selector: #selector(captureButtonTapped), name: Notification.Name.shootPicture, object: nil)
    }
    
    var lastImage: UIImage? {
        return self.imageCaptureService.lastUsedImage
    }
    
    @objc func captureButtonTapped() {
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
        self.capturedImage = self.lastImage
        self.viewBinding.preparePhotoCapturedUI?()
        self.imageCaptureService.stop()
        self.isPhotoCaptured = true
        self.startAnalysis()
    }
    
    func viewDidLoad() {
        self.imageCaptureService.requestPermission { [weak self] granted in
            guard let strongSelf = self else { return }
            guard granted else {
                strongSelf.viewBinding.showPermissionAlert?()
                return
            }
            strongSelf.setup()
        }
    }
    
    func viewDidAppear() {
        self.philipsHueService.autoConnectBridge()
    }
    
    func setup() {
        self.imageCaptureService.setup() { [weak self] previewLayer in
            guard let previewLayer = previewLayer else { return }
            self?.viewBinding.setupCameraView?(previewLayer)
        }
    }
    
    func switchCamera() {
        self.imageCaptureService.switchCamera()
        self.viewBinding.flipCameraView?()
    }
    
    func upload(image: UIImage?) {
        guard let image = image else { return }
        self.imageUploadService.upload(image: image, with: self.faceAnalysisService.createImageName(), forShare: true, completionHandler: { (succeed, link) in
            if let url = URL(string: link) {
                DispatchQueue.main.async {
                    self.viewBinding.hideActivityIndicator?(true)
                    self.viewBinding.enableActivityIndicator?(false)
                    self.viewBinding.share?(url)
                }
            }
        })
    }
    
    func philipsHueButtonTapped() {
        self.navigator.navigateToBridgeConnectionView()
    }
    
    func removeOverlays() {
        DispatchQueue.main.asyncAfter(deadline: (.now() + 0.5), execute: {
            self.viewBinding.drawOverlays?([String]())
        })
    }
    
    func retakeButtonClicked() {
        self.removeOverlays()
        self.viewBinding.flipCameraView?()
        self.viewBinding.preparePhotoRetakeUI?()
        self.isPhotoCaptured = false
    }
    
    private func startAnalysis() {
        guard var image = self.capturedImage else {
            self.viewBinding.showMessage?("No Image Captured!")
            return
        }
        let remoteName = self.faceAnalysisService.createImageName()
        
        self.viewBinding.hideActivityIndicator?(false)
        self.viewBinding.enableActivityIndicator?(true)
        
        if let cgImage = image.cgImage {
            image = UIImage(cgImage: cgImage, scale: image.scale, orientation: UIImage.Orientation.right)
        }
        
        self.imageUploadService.upload(image: image, with: remoteName, forShare: false) { [weak self] (success, link) in
            guard let strongSelf = self else { return }
            if success {
                strongSelf.viewBinding.showMessage?("Successfully uploaded.")
                strongSelf.faceAnalysisService.faceAPIAnalysis(with: link, completionHandler: { (face,error) in
                    DispatchQueue.main.async {
                        strongSelf.viewBinding.hideActivityIndicator?(true)
                        strongSelf.viewBinding.enableActivityIndicator?(false)
                    }
                    if let result = face,
                        let age = result.attributes.age,
                        let emotion = result.attributes.emotion.mostEmotion,
                        let gender = result.attributes.gender, strongSelf.isPhotoCaptured {
                        
                        var overlays = [String]()
                        overlays.append("Age: \(age)")
                        overlays.append("Gender: \(gender.capitalized)")
                        overlays.append("Emotion: \(emotion.capitalized)")
                        strongSelf.viewBinding.drawOverlays?(overlays)
                        
                        if let emotion = face?.attributes.emotion.mostEmotion {
                            let mostEmotion = Emotions(fromRawValue: emotion)
                            strongSelf.philipsHueService.changeLightsWith(mostEmotion: mostEmotion)
                        }
                    } else {
                        strongSelf.philipsHueService.anexiaDefaultLightsAction()
                        strongSelf.viewBinding.showMessage?("No face detected!")
                        
                        //Prepare retake ui
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            strongSelf.viewBinding.preparePhotoRetakeUI?()
                        })
                    }
                    
                })
            } else {
                DispatchQueue.main.async {
                    strongSelf.viewBinding.hideActivityIndicator?(true)
                    strongSelf.viewBinding.enableActivityIndicator?(false)
                    strongSelf.viewBinding.showMessage?("Upload failed!")
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        log.info("")
    }
}
