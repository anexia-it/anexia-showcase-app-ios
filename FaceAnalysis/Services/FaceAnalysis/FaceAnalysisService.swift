//
//  UploadViewModel.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 04.12.18.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore
import ProjectOxfordFace

protocol FaceAnalysisServiceProtocol {
    func createImageName() -> String
    func faceAPIAnalysis(with url: String, completionHandler: @escaping  (MPOFace?, Error?)-> ())
}

/// Manages all tasks related to analyzing faces on passed images
public class FaceAnalysisService: FaceAnalysisServiceProtocol {
    private let log = Logger()
    private let faceApiKey: String
    private let faceApiURL: String
    
    init(faceApiKey: String, faceApiURL: String) {
        self.faceApiKey = faceApiKey
        self.faceApiURL = faceApiURL
    }
    
    /// Get the documents URL on the device
    private var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Saves an image on the file system.
    ///
    /// - Parameters:
    ///   - image: the image to save
    ///   - name: the image name to use
    /// - Returns: the URL of the image on the file system after writing successfully, otherwise nil
    func saveImageAndGetPath(image: UIImage, name:String) -> URL? {
        let fileName = name
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileURL // ----> Save fileName
        }
        self.log.error("Error saving image")
        return nil
    }
    
    
    /// Creates an image name by using date and time values
    ///
    /// - Returns: the full image name
    func createImageName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMYYYY-HHmmss"
        return "IMG\(formatter.string(from: Date())).jpg"
    }
    
    
    /// Load an image from the file system
    ///
    /// - Parameters:
    ///   - fileName: the image file name
    ///   - pathOnly: if true, the func returns only the path to the image, not the image itself
    /// - Returns: A tuple of the image and URL of the image
    internal func load(fileName: String, pathOnly: Bool = false) -> (UIImage?, URL?) {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            if pathOnly {
                return (nil, fileURL)
            } else {
                return (UIImage(data: imageData), fileURL)
            }
        } catch {
            self.log.error("Error loading image : \(error)")
        }
        return (nil, nil)
    }

    /// Starts the face analysis on an external API
    ///
    /// - Parameters:
    ///   - url: the URL of the image to analyse
    ///   - completionHandler: the asny completion handler returns either as result the Face or an error
    func faceAPIAnalysis(with url: String, completionHandler: @escaping  (MPOFace?, Error?)-> ())  {
        let faceServiceClient = MPOFaceServiceClient(endpointAndSubscriptionKey: self.faceApiURL, key: self.faceApiKey)
        let attributes = [MPOFaceAttributeTypeGender.rawValue, MPOFaceAttributeTypeAge.rawValue, MPOFaceAttributeTypeHair.rawValue, MPOFaceAttributeTypeFacialHair.rawValue, MPOFaceAttributeTypeMakeup.rawValue, MPOFaceAttributeTypeEmotion.rawValue, MPOFaceAttributeTypeOcclusion.rawValue, MPOFaceAttributeTypeExposure.rawValue, MPOFaceAttributeTypeHeadPose.rawValue, MPOFaceAttributeTypeAccessories.rawValue]
        
        faceServiceClient?.detect(withUrl: url, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: attributes, completionBlock: { (collection, error) in
            if error != nil {
                self.log.error("\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            if let face = collection?.first {
                completionHandler(face, nil)
                return
            }
            completionHandler(nil, error)
        })
    }
}
