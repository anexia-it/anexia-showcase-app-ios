//
//  Emotions.swift
//  FaceAnalysis
//
//  Created by Darko Damjanovic on 28.01.19.
//  Copyright © 2019 Anexia. All rights reserved.
//

import Foundation

enum Emotions: String {
    case anger = "anger"
    case contempt = "contempt"
    case disgust = "disgust"
    case fear = "fear"
    case happiness = "happiness"
    case neutral = "neutral"
    case sadness = "sadness"
    case surprise = "surprise"
    case unknown = ""
    
    init(fromRawValue: String){
        self = Emotions(rawValue: fromRawValue) ?? .unknown
    }
}
