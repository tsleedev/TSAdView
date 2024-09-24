//
//  TSAdConsentManager.swift
//  TSAdView
//
//  Created by TAE SU LEE on 9/24/24.
//

import Foundation
import GoogleMobileAds
import UserMessagingPlatform

public class TSAdConsentManager {
    public static let shared = TSAdConsentManager()
    
    private init() {}
    
    public private(set) var debugSettings: TSAdConsentDebugSettings?
    
    public func setDebugSettings(_ settings: TSAdConsentDebugSettings?) {
        self.debugSettings = settings
    }
    
    public var canRequestAds: Bool {
        return UMPConsentInformation.sharedInstance.canRequestAds
    }
    
    public var isPrivacyOptionsRequired: Bool {
        return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
    }
    
    // Closure-based API
    public func requestConsentUpdate(from viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        let parameters = createParameters()
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] requestConsentError in
            guard requestConsentError == nil else {
                completion(requestConsentError)
                return
            }
            
            self?.showConsentFormIfRequired(from: viewController, completion: completion)
        }
    }
    
    // Async/await API
    public func requestConsentUpdate(from viewController: UIViewController) async throws {
        let parameters = createParameters()
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] requestConsentError in
                if let error = requestConsentError {
                    continuation.resume(throwing: error)
                    return
                }
                
                self?.showConsentFormIfRequired(from: viewController) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    private func createParameters() -> UMPRequestParameters {
        let parameters = UMPRequestParameters()
        
        if let settings = debugSettings {
            let debugSettings = UMPDebugSettings()
            debugSettings.testDeviceIdentifiers = settings.testDeviceIdentifiers
            debugSettings.geography = settings.geography
            parameters.debugSettings = debugSettings
        }
        
        return parameters
    }
    
    private func showConsentFormIfRequired(from viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        UMPConsentForm.loadAndPresentIfRequired(from: viewController) { loadAndPresentError in
            completion(loadAndPresentError)
            
            if loadAndPresentError == nil {
                print("Consent gathered successfully")
            }
        }
    }
    
    // Closure-based API
    public func presentPrivacyOptionsForm(from viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        UMPConsentForm.presentPrivacyOptionsForm(from: viewController, completionHandler: completion)
    }
    
    // Async/await API
    public func presentPrivacyOptionsForm(from viewController: UIViewController) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UMPConsentForm.presentPrivacyOptionsForm(from: viewController) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    public func resetConsentInformation() {
        UMPConsentInformation.sharedInstance.reset()
    }
}
