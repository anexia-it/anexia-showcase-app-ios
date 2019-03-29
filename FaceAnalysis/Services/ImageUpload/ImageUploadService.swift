//
//  ImageUploadService.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 01.03.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit
import AWSS3

protocol ImageUploadServiceProtocol {
    func upload(image : UIImage, with fileName: String, forShare: Bool, completionHandler: @escaping ((_ success:Bool,_ link:String)->Void))
}

/// Everything related to uploaded images to any web service.
class ImageUploadService: ImageUploadServiceProtocol {
    private let log = Logger()
    private let accessKey: String
    private let secretKey: String
    private let bucketName: String

    init(accessKey: String, secretKey: String, bucketName: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.bucketName = bucketName

        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.EUCentral1, credentialsProvider: credentialsProvider)

        AWSServiceManager.default()?.defaultServiceConfiguration = configuration
    }

    /// Uploads a image to AWS S3 Storage
    ///
    /// - Parameters:
    ///   - image: the image for uploading
    ///   - fileName: the filename for the image
    ///   - forShare: true if the file should be shared afterwards, otherwise false
    ///   - completionHandler: the completion handler
    func upload(image : UIImage, with fileName: String, forShare: Bool, completionHandler: @escaping ((_ success:Bool,_ link:String)->Void)){
        let transferUtility = AWSS3TransferUtility.default()
        
        //Add prefix to fileName if it is for sharing
        let key = forShare ? "share/" + fileName : fileName
        
        //Convert UIImage to data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else{
            log.error("Error during converting UIImage to jpeg")
            return
        }
        
        //Completion handler of the upload request
        let uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock? = { (task, error) -> Void in
            if let error = error {
                self.log.error("Upload failed with error: (\(error))")
                completionHandler(false, "")
            }
            else{
                // Image url from S3
                let awsEndpointUrl = AWSS3.default().configuration.endpoint.url
                let publicURL = awsEndpointUrl?.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                if let imageURLString = publicURL?.absoluteString {
                    self.log.info("Uploaded to: \(imageURLString)")
                    completionHandler(true, imageURLString)
                }
                else{
                    completionHandler(false, "")
                }
            }
        }

        //Start the upload to S3
        transferUtility.uploadData(imageData,
                                   bucket: bucketName,
                                   key: key,
                                   contentType: "image/jpeg",
                                   expression: nil,
                                   completionHandler: uploadCompletionHandler).continueWith { (task) -> Any? in

                                    //Check if there was an error (e.g. invalid credentials or bucket)
                                    if let error = task.error{
                                        self.log.error(error)
                                        completionHandler(false, "")
                                    }
                                    return nil
        }
    }
}
