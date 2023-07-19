//
//  TSAdMobBanner.swift
//  
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit
import GoogleMobileAds

class TSAdMobBanner: NSObject {
    private static var isAdMobStarted = false
    
    typealias GADBannerViewResult = Result<GADBannerView, Error>
    private var completion: ((GADBannerViewResult) -> ())?
    private var bannerAdView: GADBannerView?
    
    override init() {
        super.init()
        startAdMobIfNeeded()
    }
    
    // 적응형
    func load(rootViewController: UIViewController, adUnitID: String, adDimension: CGSize, completion: @escaping (GADBannerViewResult) -> ()) {
        self.completion = completion
        
        let bannerView = GADBannerView(adSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(adDimension.width))
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = rootViewController
        bannerView.delegate = self
        let request = GADRequest()
        #if DEBUG
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //테스트 광고
//        request.testDevices = ["87f4996deb598d6046532ec84814ebe5"]
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["87f4996deb598d6046532ec84814ebe5"]
        #endif
        bannerView.frame = CGRect(x: 0, y: 0, width: adDimension.width, height: adDimension.height)
        bannerAdView = bannerView
        bannerView.load(request)
    }
}

// MARK: - GADBannerViewDelegate
extension TSAdMobBanner: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(String(describing: type(of: self)) + " adViewDidReceiveAd")
        if let adNetworkClassName = bannerView.responseInfo?.adNetworkClassName {
            print("Banner adapter class name: \(adNetworkClassName)")
        }
        completion?(.success(bannerView))
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        completion?(.failure(error))
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(String(describing: type(of: self)) + " adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(String(describing: type(of: self)) + " adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(String(describing: type(of: self)) + " adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func bannerViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print(String(describing: type(of: self)) + " adViewWillLeaveApplication")
    }
}

// MARK: - Helper
private extension TSAdMobBanner {
    func startAdMobIfNeeded() {
        guard !TSAdMobBanner.isAdMobStarted else { return }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        TSAdMobBanner.isAdMobStarted = true
    }
}
