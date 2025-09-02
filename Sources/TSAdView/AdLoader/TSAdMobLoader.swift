//
//  TSAdMobLoader.swift
//
//
//  Created by TAE SU LEE on 2023/07/19.
//

import Foundation
import Combine
import GoogleMobileAds

class TSAdMobLoader: NSObject {
    private static var isAdMobStarted = false
    private var bannerAdView: BannerView?
    
    private var bannerViewSubject = PassthroughSubject<BannerView, Error>()
    var bannerViewPublisher: AnyPublisher<BannerView, Error> {
        bannerViewSubject.eraseToAnyPublisher()
    }
    
    func load(rootViewController: UIViewController, adUnitID: String, adDimension: CGSize) {
        let bannerView = BannerView(adSize: currentOrientationAnchoredAdaptiveBanner(width: adDimension.width))
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = rootViewController
        bannerView.delegate = self
        bannerView.frame = CGRect(x: 0, y: 0, width: adDimension.width, height: adDimension.height)
        bannerAdView = bannerView
        
        if TSAdConsentManager.shared.canRequestAds {
            startGoogleMobileAdsSDK()
        } else {
            TSAdConsentManager.shared.requestConsentUpdate(from: rootViewController) { [weak self] (consentError) in
                guard let self else { return }
                
                if let consentError {
                    // Consent gathering failed.
                    print("Error: \(consentError.localizedDescription)")
                    bannerViewSubject.send(completion: .failure(consentError))
                } else {
                    if TSAdConsentManager.shared.canRequestAds {
                        self.startGoogleMobileAdsSDK()
                    }
                }
            }
        }
    }
    
    private func startGoogleMobileAdsSDK() {
        DispatchQueue.main.async {
            // Initialize the Google Mobile Ads SDK.
            self.startAdMobIfNeeded()
            self.bannerAdView?.load(Request())
        }
    }
}

// MARK: - GADBannerViewDelegate
extension TSAdMobLoader: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " adViewDidReceiveAd")
        if let adNetworkClassName = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName {
            print("Banner adapter class name: \(adNetworkClassName)")
        }
        bannerViewSubject.send(bannerView)
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        bannerViewSubject.send(completion: .failure(error))
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func bannerViewWillLeaveApplication(_ bannerView: BannerView) {
        print(String(describing: type(of: self)) + " adViewWillLeaveApplication")
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
