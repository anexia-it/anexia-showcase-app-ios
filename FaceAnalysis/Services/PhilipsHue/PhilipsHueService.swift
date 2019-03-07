//
//  PhilipsHueService.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 07.02.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import UIKit

protocol PhilipsHueServiceProtocol {
    var lastConnectedBridge: PHBridgeInfo? { get }
    var bridge: PHSBridge? { get }
    var selectedBridge: PHBridgeInfo? { get  set }
    var authenticated: (() -> ())? { get set }
    var notAuthenticated: (() -> ())? { get set }
    
    func autoConnectBridge()
    func changeLightsWith(mostEmotion: Emotions)
    func anexiaDefaultLightsAction()
}


/// Manages all tasks regarding Philips HUE light bulbs.
class PhilipsHueService: NSObject, PhilipsHueServiceProtocol {
    private let log = Logger()
    var pushLinkVC: PushLinkViewController? = nil
    var bridge: PHSBridge? = nil
    var selectedBridge: PHBridgeInfo?
    var authenticated: (() -> ())?
    var notAuthenticated: (() -> ())?
    
    typealias HUEValue = (hue: NSNumber?, saturation: NSNumber?, brightness: NSNumber?)

    private let anexiaWhiteColor: HUEValue
    private let anexiaBlueColor: HUEValue
    private let anexiaGreenColor: HUEValue
    
    override init() {
        anexiaWhiteColor = PhilipsHueService.rgbToHue(r: 254, g: 254, b: 254)
        anexiaBlueColor = PhilipsHueService.rgbToHue(r: 0, g: 60, b: 166)
        anexiaGreenColor = PhilipsHueService.rgbToHue(r: 119, g: 188, b: 31)
        super.init()
    }
    
    var lastConnectedBridge: PHBridgeInfo? {
        if let lastConnectedBridge = self.lastConnectedBridgeInternal {
            return PHBridgeInfo(ipAddress: lastConnectedBridge.ipAddress, uniqueID: lastConnectedBridge.uniqueId)
        }
        return nil
    }
    
    
    /// Turn on the default lights with Anexia colors white, blue and green
    func anexiaDefaultLightsAction() {
        if let devices = self.bridge?.bridgeState.getDevicesOf(.light) as? [PHSDevice] {
            var index = 0
            for device in devices {
                if let lightPoint = device as? PHSLightPoint {
                    let lightState = self.lightStateWithAnexiaColors(index: index)
                    index += 1
                    lightPoint.update(lightState, allowedConnectionTypes: .local, completionHandler: { (response, errors, returnCode) in
                        if errors != nil {
                            for error in errors! {
                                self.log.error(error.debugDescription)
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    /// Sets the light to default Anexia colors
    ///
    /// - Parameter index: the index of the current light bulb
    /// - Returns: the light state
    private func lightStateWithAnexiaColors(index: Int) -> PHSLightState {
        let lightState = PHSLightState()
        lightState.on = true
        
        switch index {
        case 0:
            (lightState.hue, lightState.saturation, lightState.brightness) = self.anexiaBlueColor
            break
        case 1:
            (lightState.hue, lightState.saturation, lightState.brightness) = self.anexiaGreenColor
            break
        case 2:
            (lightState.hue, lightState.saturation, lightState.brightness) = self.anexiaWhiteColor
            break
        default:
            lightState.hue = Int(arc4random_uniform(UInt32(65535))) as NSNumber
            lightState.brightness = Int(arc4random_uniform(UInt32(254))) as NSNumber
        }
        return lightState
    }
    
    
    /// Changes the lights depending on the emotion
    ///
    /// - Parameter mostEmotion: the emotion to visualise
    func changeLightsWith(mostEmotion: Emotions) {
        let lightState = PHSLightState()
        lightState.on = true
        
        switch mostEmotion {
            
        case .anger:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 254, g: 0, b: 0)
        case .contempt:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 50, g: 140, b: 40)
            
        case .disgust:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 128, g: 238, b: 111)
            
        case .fear:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 255, g: 0, b: 0)
            
        case .happiness:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 244, g: 226, b: 66)
            
        case .neutral:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 252, g: 252, b: 252)
            
        case .sadness:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 43, g: 3, b: 180)
            
        case .surprise:
            (lightState.hue, lightState.saturation, lightState.brightness) = PhilipsHueService.rgbToHue(r: 250, g: 170, b: 3)
            
        default:
            break
        }
        applyLightsChange(lightState: lightState)
    }
    
    
    /// Applye the actal light change
    ///
    /// - Parameter lightState: the light state to set
    private func applyLightsChange(lightState: PHSLightState) {
        if let devices = self.bridge?.bridgeState.getDevicesOf(.light) as? [PHSDevice] {
            for device in devices {
                if let lightPoint = device as? PHSLightPoint {
                    let lightState = lightState
                    
                    lightPoint.update(lightState, allowedConnectionTypes: .local, completionHandler: { (response, errors, returnCode) in
                        if errors != nil {
                            for error in errors! {
                                self.log.error(error.debugDescription)
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    /// Try to connect automatically to a HUE bridge
    func autoConnectBridge() {
        if let selectedBridge = self.selectedBridge {
            self.bridge = self.buildBridge(with: selectedBridge)
            self.bridge?.connect()
            return
        }
        
        guard self.lastConnectedBridge == nil else {
            self.bridge = self.buildBridge(with: self.lastConnectedBridge!)
            self.bridge?.connect()
            return
        }
    }
    
    
    /// The last connected bridge
    private var lastConnectedBridgeInternal: PHSKnownBridge? {
        let knownBridges: [PHSKnownBridge] = PHSKnownBridges.getAll()
        let sortedKNownBridges: [PHSKnownBridge] = knownBridges.sorted { ( bridge1, bridge2) -> Bool in
            return bridge1.lastConnected < bridge2.lastConnected
        }
        return sortedKNownBridges.first
    }

    
    /// Builds a PHSBridge type
    ///
    /// - Parameter info: the PHBridgeInfo
    /// - Returns: the PHSBridge type
    private func buildBridge(with info: PHBridgeInfo) -> PHSBridge {
        return PHSBridge.init(block: { (builder) in
            builder?.connectionTypes = .local
            builder?.ipAddress = info.ipAddress
            builder?.bridgeID = info.uniqueID
            builder?.bridgeConnectionObserver = self
            builder?.add(self)
        }, withAppName: "PhiliphsHueDemo", withDeviceName: "iPhoneX")
    }
    
    
    /// Converts an RGB color value to HUE
    ///
    /// - Parameters:
    ///   - r: the red component
    ///   - g: the green component
    ///   - b: the blue componenet
    /// - Returns: the HUE color value
    private class func rgbToHue(r:CGFloat,g:CGFloat,b:CGFloat) -> HUEValue {
        let minV:CGFloat = CGFloat(min(r, g, b))
        let maxV:CGFloat = CGFloat(max(r, g, b))
        let delta:CGFloat = maxV - minV
        var hue:CGFloat = 0
        if delta != 0 {
            if r == maxV {
                hue = (g - b) / delta
            }
            else if g == maxV {
                hue = 2 + (b - r) / delta
            }
            else {
                hue = 4 + (r - g) / delta
            }
            hue *= 60
            if hue < 0 {
                hue += 360
            }
        }
        let saturation = maxV == 0 ? 0 : (delta / maxV)
        let brightness = maxV

        return (NSNumber(value: Float(hue/360 * 65535)), NSNumber(value: Float(saturation*254)), NSNumber(value: Float(brightness)))
    }
}


// MARK: - PHSBridgeConnectionObserver, PHSBridgeStateUpdateObserver
extension PhilipsHueService: PHSBridgeConnectionObserver, PHSBridgeStateUpdateObserver {
    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handle connectionEvent: PHSBridgeConnectionEvent) {
        switch connectionEvent {
        case .authenticated:
            self.authenticated?()
            self.anexiaDefaultLightsAction()
            self.log.info("authenticated")
            break
        case .connected:
            self.log.info("connected")
            break
        case .linkButtonNotPressed:
            self.log.info("linkButtonNotPressed")
            break
        case .notAuthenticated:
            self.notAuthenticated?()
            self.log.info("notAuthenticated")
            break
        default:
            return
        }
    }
    
    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handleErrors connectionErrors: [PHSError]!) {
        self.log.error(connectionErrors)
    }
    
    func bridge(_ bridge: PHSBridge!, handle updateEvent: PHSBridgeStateUpdatedEvent) {
        switch updateEvent {
        case .bridgeConfig:
            break
        case .fullConfig:
            break
        case .initialized:
            break
        default:
            return
        }
    }
}

