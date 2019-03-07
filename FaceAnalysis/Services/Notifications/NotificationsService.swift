//
//  NotificationsService.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 14.02.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation
import PubNub

protocol NotificationsServiceProtocol {
    init(publishKey: String, subscribeKey: String)
    func appOpened()
}

/// Manages PubSub Notifications which are sent from the Alexa Client.
/// The Alexa client sends a command to shoot a picture on the device.
class NotificationsService: NSObject, PNObjectEventListener, NotificationsServiceProtocol {
    private let publishKey: String
    private let subscribeKey: String
    private let channelName = "shoot_picture"
    private let log = Logger()
    
    // Stores reference on PubNub client to make sure what it won't be released.
    private var client: PubNub?
    
    
    /// The initializer.
    /// - Remark: currently the App does not publish events
    /// - Parameters:
    ///   - publishKey: the needed key for publisihing on channels
    ///   - subscribeKey: the needed key for subscribing to channels
    required init(publishKey: String, subscribeKey: String) {
        self.publishKey = publishKey
        self.subscribeKey = subscribeKey
        super.init()
    }
    
    /// Will be called on App opened
    func appOpened() {
        // Initialize and configure PubNub client instance
        let configuration = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client?.addListener(self)
        
        // Subscribe to demo channel with presence observation
        self.client?.subscribeToChannels([channelName], withPresence: false)
    }
    
    /// Handle new message from one of channels on which client has been subscribed.
    ///
    /// - Parameters:
    ///   - client: the PubNub client
    ///   - message: the received message
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if message.data.channel == self.channelName {
            // Message received, shoot the picture
            NotificationCenter.default.post(name: Notification.Name.shootPicture, object: nil)
            log.info(message.data.channel)
        }
    }
}
