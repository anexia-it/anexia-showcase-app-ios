//
//  DependencyContainer.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 19.02.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

protocol DependencyContainerProtocol {
    var configuration: ConfigurationProtocol { get }
    var notificationsService: NotificationsServiceProtocol { get }
    var faceAnalysisService: FaceAnalysisServiceProtocol { get }
    var userDefaults: UserDefaults { get }
    var philipsHueService: PhilipsHueServiceProtocol { get }
    var imageUploadService: ImageUploadService { get }
}

/// Holds all shared dependencies for the Application.
/// The Swift lazy feature is used here to create a correct dependency injection tree with only single instances.
/// It doesn't matter which dependency is loaded first, it will automatically create all
/// it's needed dependencies here and they will be injected.
class DependencyContainer: DependencyContainerProtocol {
    private(set) lazy var configuration: ConfigurationProtocol = Configuration()
    
    private(set) lazy var notificationsService: NotificationsServiceProtocol =
        NotificationsService(
            publishKey: self.configuration.pubNubPublishKey,
            subscribeKey: self.configuration.pubNubSubscribeKey
        )
    
    private(set) lazy var philipsHueService: PhilipsHueServiceProtocol = PhilipsHueService()
    
    private(set) lazy var faceAnalysisService: FaceAnalysisServiceProtocol =
        FaceAnalysisService(
            faceApiKey: self.configuration.faceApiKey,
            faceApiURL: self.configuration.faceApiURL
        )
    
    private(set) lazy var imageUploadService: ImageUploadService =
        ImageUploadService(
            accessKey: self.configuration.accessKeyS3,
            secretKey: self.configuration.secretKeyS3,
            bucketName: self.configuration.bucketNameS3
    )

    /// Using own user defaults instead of UserDefaults.standards enables unit testing of UserDefaults.
    /// In the corresponding unit test another user default is created and so we have isolated tests.
    private(set) lazy var userDefaults: UserDefaults = UserDefaults(suiteName: self.configuration.userDefaultsName)!
}
