//
//  Configuration.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 19.02.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

protocol ConfigurationProtocol {
    var userDefaultsName: String { get }
    var pubNubPublishKey: String { get }
    var pubNubSubscribeKey: String { get }
    var faceApiKey: String { get }
    var faceApiURL: String { get }
    var accessKeyS3: String { get }
    var secretKeyS3: String { get }
    var bucketNameS3: String { get }
}

fileprivate struct Config: Codable {
    let userDefaultsName: String
    let pubNubPublishKey: String
    let pubNubSubscribeKey: String
    let faceApiKey: String
    let faceApiURL: String
    let accessKeyS3: String
    let secretKeyS3: String
    let bucketNameS3: String
}


/// Reads all config values from local plist files.
/// The values can aferwards be read over the DependencyContainer.
class Configuration {
    private let config: Config
    
    init() {
        let fileUrl = Bundle.main.url(forResource: "Config", withExtension: "plist")!
        let plistDecoder = PropertyListDecoder()
        let data = try! Data.init(contentsOf: fileUrl)
        config = try! plistDecoder.decode(Config.self, from: data)
    }
}

// MARK: - ConfigurationProtocol
extension Configuration: ConfigurationProtocol {
    var userDefaultsName: String {
        return self.config.userDefaultsName
    }
    
    var pubNubPublishKey: String {
        return self.config.pubNubPublishKey
    }
    
    var pubNubSubscribeKey: String {
        return self.config.pubNubSubscribeKey
    }
    
    var faceApiKey: String {
        return self.config.faceApiKey
    }
    
    var faceApiURL: String {
        return self.config.faceApiURL
    }
    
    var accessKeyS3: String {
        return self.config.accessKeyS3
    }
    
    var secretKeyS3: String  {
        return self.config.secretKeyS3
    }

    var bucketNameS3: String {
        return self.config.bucketNameS3
    }

}
