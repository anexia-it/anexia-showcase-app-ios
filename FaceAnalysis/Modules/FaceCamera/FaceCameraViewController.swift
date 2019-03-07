//
//  FaceCameraViewController.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/// The view controller controls the lifecycle of views and holds also all views.
/// In the MVVM pattern the view controller is the representation of the general "View".
class FaceCameraViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var squareOverlay: UIView!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var cameraCaptureButton: UIButton!
    @IBOutlet weak var lastImageView: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var philipsHueButton: UIButton!
    
    private let log = Logger()
    var viewModel: FaceCameraViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)
        self.bindViewModel()
        self.viewModel.viewDidLoad()
    }
    
    private func bindViewModel() {
        viewModel.viewBinding.drawOverlays = { [weak self] overlays  in
            self?.draw(overlays: overlays)
        }
        
        viewModel.viewBinding.drawOverlays = { [weak self] overlays  in
            self?.draw(overlays: overlays)
        }
        
        viewModel.viewBinding.flipCameraView = { [weak self] in
            self?.cameraView.flipAnimationCurlUp()
        }
        
        viewModel.viewBinding.preparePhotoRetakeUI = { [weak self] in
            self?.preparePhotoRetakeUI()
        }
        
        viewModel.viewBinding.share = { [weak self] url in
            self?.share(url: url)
        }
        
        viewModel.viewBinding.enableActivityIndicator =  { [weak self] enable in
            if enable {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.viewBinding.hideActivityIndicator = { [weak self] hidden in
            self?.activityIndicator.isHidden = hidden
        }
        
        viewModel.viewBinding.showMessage = { [weak self] message in
            self?.showToast(message: message)
        }
        
        viewModel.viewBinding.preparePhotoCapturedUI = { [weak self] in
            self?.preparePhotoCapturedUI()
        }
        
        viewModel.viewBinding.setupCameraView = { [weak self] videoPreviewLayer in
            self?.setupCameraView(videoPreviewLayer: videoPreviewLayer)
        }
        
        viewModel.viewBinding.showPermissionAlert = { [weak self] in
            self?.showNeedPermissionAlert()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    /// First removes all existing overlays and then draws new one.
    /// If the passed string array is empty, just removal happens.
    ///
    /// - Parameter overlays: the texts for each overlay to show
    func draw(overlays: [String]) {
        self.view.subviews.forEach {
            if $0 is TextOverlayView {
                $0.removeFromSuperview()
            }
        }
        
        var lastOverlay: UIView?
        for text in overlays {
            let overlayView = TextOverlayView()
            overlayView.setText(text: text)
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(overlayView)
            
            let bottomAnchor = lastOverlay?.topAnchor ?? view.bottomAnchor
            let bottomConstant: CGFloat = lastOverlay == nil ? -30 : -8
            overlayView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomConstant).isActive = true
            overlayView.heightAnchor.constraint(equalToConstant: 38).isActive = true
            overlayView.widthAnchor.constraint(equalToConstant: 220).isActive = true
            lastOverlay = overlayView
            
            self.view.bringSubviewToFront(overlayView)
        }
        
        if !overlays.isEmpty {
            lastImageView.isHidden = true
            self.shareButton.isEnabled = true
        }
    }
    
    @IBAction func captureButtonTapped() {
        self.viewModel.captureButtonTapped()
    }
    
    @IBAction func philipsHueButtonTapped(_ sender: Any) {
        self.viewModel.philipsHueButtonTapped()
    }
    
    @IBAction func switchCameraButtonClicked(){
        viewModel.switchCamera()
    }
    
    // MARK: - Button Actions
    @IBAction func retakeButtonClicked(_ sender: Any) {
        viewModel.retakeButtonClicked()
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        self.activityIndicator.startAnimating()
        createResultImage { [weak self] (resultImage) in
            self?.viewModel.upload(image: resultImage)
        }
    }
    
    /// Show an alert with a link to settings to change permission
    private func showNeedPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera access",
            message: "Camera access is required for this app. You can change the permission in the settings.",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) -> Void in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupCameraView(videoPreviewLayer: AVCaptureVideoPreviewLayer) {
        self.cameraView.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = self.cameraView.layer.bounds
        self.cameraView.bringSubviewToFront(self.cameraCaptureButton)
        self.cameraView.bringSubviewToFront(self.cameraSwitchButton)
        self.cameraView.bringSubviewToFront(self.squareOverlay)
        self.cameraView.bringSubviewToFront(self.lastImageView)
        self.cameraView.bringSubviewToFront(self.retakeButton)
        self.cameraView.bringSubviewToFront(self.retakeButton)
        self.cameraView.bringSubviewToFront(self.activityIndicator)
        self.cameraView.bringSubviewToFront(self.shareButton)
        self.cameraView.bringSubviewToFront(self.philipsHueButton)
    }
    
    private func preparePhotoCapturedUI() {
        self.retakeButton.isHidden = false
        self.lastImageView.isHidden = false
        self.lastImageView.image = self.viewModel.lastImage
        self.cameraSwitchButton.isHidden = true
        self.cameraCaptureButton.isHidden = true
        self.shareButton.isHidden = false
        self.philipsHueButton.isHidden = false
    }
    
    private func preparePhotoRetakeUI() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.retakeButton.isHidden = true
        self.lastImageView.isHidden = true
        self.cameraSwitchButton.isHidden = false
        self.cameraCaptureButton.isHidden = false
        self.shareButton.isHidden = true
        self.philipsHueButton.isHidden = true
        self.shareButton.isEnabled = false
        self.viewModel.setup()
    }
    
    private func share(url: URL) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        let title = "Share your result."
        let activityViewController = UIActivityViewController(
            activityItems: [title, url],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true,completion: nil)
    }
    
    /// Renders an UIImage as a screenshot of the current screen.
    /// The overlays are included in teh screenshot.
    ///
    /// - Parameter completionHandler: the asny completion handler with the resulting image
    private func createResultImage(completionHandler: @escaping (_ resultImage: UIImage?) -> ()) {
        DispatchQueue.main.async {
            self.retakeButton.isHidden = true
            self.shareButton.isHidden = true
            self.activityIndicator.isHidden = true
            self.lastImageView.isHidden = false
            
            var screenshotImage :UIImage?
            let layer = UIApplication.shared.keyWindow!.layer
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            guard let context = UIGraphicsGetCurrentContext() else {return}
            layer.render(in:context)
            screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let img = screenshotImage {
                completionHandler(img)
            }
            self.activityIndicator.isHidden = false
            self.retakeButton.isHidden = false
            self.shareButton.isHidden = false
            self.shareButton.isEnabled = true
        }
    }
    
    deinit {
        log.info("")
    }
}
