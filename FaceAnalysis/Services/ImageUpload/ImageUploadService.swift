//
//  ImageUploadService.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 01.03.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import UIKit

protocol ImageUploadServiceProtocol {
    func upload(image : UIImage, with fileName: String, forShare: Bool, completionHandler: @escaping ((_ success:Bool,_ link:String)->Void))
}

/// Everything related to uploaded images to any web service.
class ImageUploadService: ImageUploadServiceProtocol {
    private let log = Logger()
    
    /// Uploads image to a temprary Web Service. TODO: this shall be replaced with S3 upload
    ///
    /// - Parameters:
    ///   - image: the image for uploading
    ///   - fileName: the filename for the image
    ///   - forShare: true if the file should be shared afterwards, otherwise false
    ///   - completionHandler: the completion handler
    func upload(image : UIImage, with fileName: String, forShare: Bool, completionHandler: @escaping ((_ success:Bool,_ link:String)->Void)){
        let url = forShare ? URL(string: "http://anexia.safakli.com/uploadshare.php") :  URL(string: "http://anexia.safakli.com/upload.php")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)",forHTTPHeaderField: "Content-Type")
        
        let image_data = image.jpegData(compressionQuality: 0.5)
        guard image_data != nil else {
            return
        }
        
        let body = NSMutableData()
        let fname = fileName
        let contentType = "multipart/form-data; boundary=\(boundary)"
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body as Data
        
        let session = URLSession.shared
        let uploadTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                self.log.info("error while uploadTask \(String(describing: error))")
                completionHandler(false,"error while uploadTask \(error.debugDescription).")
                return
            }
            guard data != nil else {
                self.log.info("no data at uploadTask")
                completionHandler(false,"Got no response from Imagecloud.")
                return
            }
            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                
                if dataString == "success"{
                    completionHandler(true, forShare ? "http://anexia.safakli.com/Uploads/share/\(fileName)" : "http://anexia.safakli.com/Uploads/\(fileName)")
                } else {
                    completionHandler(false,String(dataString))
                }
            }
        })
        uploadTask.resume()
    }
}
