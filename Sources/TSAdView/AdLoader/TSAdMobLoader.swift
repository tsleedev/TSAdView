//
//  TSAdMobLoader.swift
//
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit
import GoogleMobileAds

@MainActor
final class TSAdMobLoader: NSObject {
    private static var isAdMobStarted = false
    private var bannerView: BannerView?
    private var continuation: CheckedContinuation<BannerView, Error>?

    func load(rootViewController: UIViewController, adUnitID: String, adDimension: CGSize) async throws -> BannerView {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let bannerView = BannerView(adSize: currentOrientationAnchoredAdaptiveBanner(width: adDimension.width))
            bannerView.adUnitID = adUnitID
            bannerView.rootViewController = rootViewController
            bannerView.delegate = self
            bannerView.frame = CGRect(x: 0, y: 0, width: adDimension.width, height: adDimension.height)
            self.bannerView = bannerView

            Task {
                do {
                    if !TSAdConsentManager.shared.canRequestAds {
                        try await TSAdConsentManager.shared.requestConsentUpdate(from: rootViewController)
                    }

                    guard TSAdConsentManager.shared.canRequestAds else {
                        self.resumeWithError(NSError(domain: "TSAdMobLoader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot request ads"]))
                        return
                    }

                    self.startAdMobIfNeeded()
                    bannerView.load(Request())
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

    private func resumeWithSuccess(_ bannerView: BannerView) {
        continuation?.resume(returning: bannerView)
        continuation = nil
    }
}

// MARK: - BannerViewDelegate
extension TSAdMobLoader: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " bannerViewDidReceiveAd")
        if let adNetworkClassName = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName {
            print("Banner adapter class name: \(adNetworkClassName)")
        }
        resumeWithSuccess(bannerView)
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        resumeWithError(error)
    }

    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " bannerViewWillDismissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " bannerViewDidDismissScreen")
    }
}

// MARK: - Helper
private extension TSAdMobLoader {
    func startAdMobIfNeeded() {
        guard !TSAdMobLoader.isAdMobStarted else { return }
        MobileAds.shared.start(completionHandler: nil)
        TSAdMobLoader.isAdMobStarted = true
    }
}
