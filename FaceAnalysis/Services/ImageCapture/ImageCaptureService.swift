//
//  ImageCaptureService.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 19.02.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import UIKit
import AVFoundation

protocol ImageCaptureServiceProtocol {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? { get }
    var lastUsedImage: UIImage? { get }
    var isUsingFrontCamera: Bool { get }
    
    func setup(completion: @escaping (AVCaptureVideoPreviewLayer?) -> ())
    func startRecording()
    func stop()
    func requestPermission(completion: @escaping (_ success: Bool) -> ())
    func resizePreview(_ bounds: CGRect)
    func switchCamera()
}


/// Manages capturing video streams and images and delivering it.
class ImageCaptureService: NSObject, ImageCaptureServiceProtocol {
    private let log = Logger()
    
    private var captureSession: AVCaptureSession
    private(set) var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private(set) var lastUsedImage: UIImage?
    private var videoOutput: AVCaptureVideoDataOutput?
    private(set) var isUsingFrontCamera = true
    private let backgroundQueue = DispatchQueue(label: "com.anexia-it.internal.showcase.ml.capturequeue")
    
    override init() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1280x720
        super.init()
    }
    
    
    /// Setup the video recording
    ///
    /// - Parameter completion: The asny completion handler.
    func setup(completion: @escaping (AVCaptureVideoPreviewLayer?) -> ()) {
        backgroundQueue.async {
            self.setup(self.isUsingFrontCamera, completion: completion)
        }
    }
    
    /// Start recording and take the first photo
    func startRecording() {
        backgroundQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    /// Switches between front and back camera
    func switchCamera() {
        if let camera = getCaptureDeviceInput(!isUsingFrontCamera){
            isUsingFrontCamera = !isUsingFrontCamera
            captureSession.inputs.forEach{captureSession.removeInput($0)}
            captureSession.addInput(camera)
        }
    }

    /// App will be closed
    @objc func stop() {
        captureSession.stopRunning()
        captureSession.inputs.forEach{ captureSession.removeInput($0) }
        captureSession.outputs.forEach{ captureSession.removeOutput($0) }
    }
    
    
    /// Check camera access
    ///
    /// - Parameter completion: The asny completion handler.
    func requestPermission(completion: @escaping (_ success: Bool) -> ()) {
        if AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                guard granted else { completion(false); return }
                completion(true)
            })
        } else {
            completion(true)
        }
    }
    
    /// Resize the previewLayer
    ///
    /// - Parameter bounds: new bounds for the previewLayer
    func resizePreview(_ bounds: CGRect) {
        self.videoPreviewLayer?.frame = bounds
    }
    
    /// Setup the camera for streaming video
    ///
    /// - Parameters:
    ///   - frontCamera: boolean indicating if front camera should be used
    ///   - completion: the asny completion handler
    private func setup(_ frontCamera: Bool, completion: @escaping  (AVCaptureVideoPreviewLayer?) -> ()){
        if captureSession.inputs.count > 0{
            return
        }
        guard let input = getCaptureDeviceInput(frontCamera) else { return}
        
        if captureSession.canAddInput(input){
            captureSession.addInput(input)
        } else {
            log.warning("captureSession cannot add input")
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = .portrait
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: kCVPixelFormatType_32BGRA]
        videoOutput?.alwaysDiscardsLateVideoFrames = true
        
        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput){
            captureSession.addOutput(videoOutput)
        } else {
            log.warning("captureSession cannot add output")
        }
        
        captureSession.commitConfiguration()
        videoOutput?.setSampleBufferDelegate(self, queue: backgroundQueue)
        startRecording()
        DispatchQueue.main.async {
            completion(self.videoPreviewLayer)
        }
    }
    
    /// Get a AVCaptureDeviceInput
    ///
    /// - Parameter frontCamera: boolean indicating if front camera should be used
    /// - Returns: returns a AVCaptureDeviceInput or nil if it failed
    private func getCaptureDeviceInput(_ frontCamera: Bool = true) -> AVCaptureDeviceInput?{
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: frontCamera ? .front : .back) else {
            log.error("Error: Camera not available")
            return nil
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            return input
        }
        catch{
            log.warning("Error initializing camera \(error)")
            return nil
        }
    }
    
    
    /// Creates an UIImage out of the sample buffer
    ///
    /// - Parameter sampleBuffer: the sample buffer
    /// - Returns: the converted buffer to UIImage
    private func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: 1, orientation: isUsingFrontCamera ? .leftMirrored : .right)
            }
        }
        return nil
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ImageCaptureService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) {
            self.lastUsedImage = outputImage
        }
    }
}
