//
//  TSAdMobNativeLoader.swift
//
//
//  Created by TAE SU LEE on 2026/07/06.
//

import UIKit
import GoogleMobileAds

@MainActor
final class TSAdMobNativeLoader: NSObject {
    private var adLoader: AdLoader?
    private var nativeAd: NativeAd?
    private var continuation: CheckedContinuation<NativeAd, Error>?

    func load(rootViewController: UIViewController, adUnitID: String, mediaAspectRatio: MediaAspectRatio) async throws -> NativeAd {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            Task {
                do {
                    if !TSAdConsentManager.shared.canRequestAds {
                        try await TSAdConsentManager.shared.requestConsentUpdate(from: rootViewController)
                    }

                    guard TSAdConsentManager.shared.canRequestAds else {
                        self.resumeWithError(NSError(domain: "TSAdMobNativeLoader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot request ads"]))
                        return
                    }

                    TSAdMobInitializer.startIfNeeded()

                    let mediaOptions = NativeAdMediaAdLoaderOptions()
                    mediaOptions.mediaAspectRatio = mediaAspectRatio

                    let adLoader = AdLoader(
                        adUnitID: adUnitID,
                        rootViewController: rootViewController,
                        adTypes: [.native],
                        options: [mediaOptions]
                    )
                    adLoader.delegate = self
                    self.adLoader = adLoader
                    adLoader.load(Request())
                } catch {
                    self.resumeWithError(error)
                }
            }
        }
    }

    private func resumeWithError(_ error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    private func resumeWithSuccess(_ nativeAd: NativeAd) {
        continuation?.resume(returning: nativeAd)
        continuation = nil
    }
}

// MARK: - NativeAdLoaderDelegate
extension TSAdMobNativeLoader: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print(String(describing: type(of: self)) + " adLoader:didReceive:")
        if let adNetworkClassName = nativeAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName {
            print("Native adapter class name: \(adNetworkClassName)")
        }
        self.nativeAd = nativeAd
        resumeWithSuccess(nativeAd)
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " adLoader:didFailToReceiveAdWithError: \(error.localizedDescription)")
        resumeWithError(error)
    }
}
