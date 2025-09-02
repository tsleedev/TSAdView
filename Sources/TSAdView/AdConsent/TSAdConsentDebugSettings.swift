//
//  TSAdConsentDebugSettings.swift
//  TSAdView
//
//  Created by TAE SU LEE on 9/24/24.
//

import Foundation
import UserMessagingPlatform

public struct TSAdConsentDebugSettings {
    public let testDeviceIdentifiers: [String]
    public let geography: DebugGeography
    
    public init(testDeviceIdentifiers: [String], geography: DebugGeography) {
        self.testDeviceIdentifiers = testDeviceIdentifiers
        self.geography = geography
    }
}
