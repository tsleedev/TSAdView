//
//  TSAdManagerLoader.swift
//
//
//  Created by TAE SU LEE on 2023/07/20.
//

import UIKit
import GoogleMobileAds

final class TSAdManagerLoader: NSObject {
    private var adLoader: AdLoader?
    private var customNativeAds: [CustomNativeAd] = []
    private var continuation: CheckedContinuation<[CustomNativeAd], Error>?
    private var loadError: Error?

    private let rootViewController: UIViewController
    private let adFormatIDs: [String]
    private let adUnitID: String
    private let customTargeting: [String: String]?

    init(rootViewController: UIViewController, adFormatIDs: [String], adUnitID: String, customTargeting: [String: String]?) {
        self.rootViewController = rootViewController
        self.adFormatIDs = adFormatIDs
        self.adUnitID = adUnitID
        self.customTargeting = customTargeting
        super.init()
    }

    func load() async throws -> [CustomNativeAd] {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.customNativeAds = []
            self.loadError = nil

            let adLoader = AdLoader(
                adUnitID: adUnitID,
                rootViewController: rootViewController,
                adTypes: [.customNative],
                options: []
            )
            adLoader.delegate = self
            self.adLoader = adLoader

            let adRequest = AdManagerRequest()
            adRequest.customTargeting = customTargeting
            adLoader.load(adRequest)
        }
    }
}

// MARK: - CustomNativeAdLoaderDelegate
extension TSAdManagerLoader: CustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: AdLoader) -> [String] {
        return adFormatIDs
    }

    func adLoader(_ adLoader: AdLoader, didReceive customNativeAd: CustomNativeAd) {
        print(String(describing: type(of: self)) + " adLoader:didReceive: \(customNativeAd)")
        customNativeAds.append(customNativeAd)
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " adLoader:didFailToReceiveAdWithError: \(error.localizedDescription)")
        loadError = error
    }

    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        print(String(describing: type(of: self)) + " adLoaderDidFinishLoading")
        if customNativeAds.isEmpty {
            let error = loadError ?? NSError(domain: "TSAdManagerLoader", code: 0, userInfo: [NSLocalizedDescriptionKey: "No ads received"])
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume(returning: customNativeAds)
        }
        continuation = nil
    }
}
