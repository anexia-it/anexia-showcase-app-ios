//
//  AppDelegate.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 05.11.18.
//  Copyright © 2019 Anexia. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var dependencyContainer: DependencyContainerProtocol = DependencyContainer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        configureSDK()
        dependencyContainer.notificationsService.appOpened()
        
        launchUI()
        return true
    }
    
    /// Launch the UI removeObserver programatically.
    /// This gives us the chance to inject the root dependencies.
    private func launchUI() {
        let builder = FaceCameraBuilder(dependencyContainer: self.dependencyContainer)
        let view = builder.build()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = view
        self.window!.makeKeyAndVisible()
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func configureSDK() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        PHSPersistence.setStorageLocation(documentsPath, andDeviceId: UIDevice.current.identifierForVendor?.uuidString)
        PHSLog.setConsoleLogLevel(.debug)
    }
}

