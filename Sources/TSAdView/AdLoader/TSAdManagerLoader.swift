//
//  TSAdManagerLoader.swift
//  
//
//  Created by TAE SU LEE on 2023/07/20.
//

import Foundation
import GoogleMobileAds

class TSAdManagerLoader: NSObject {
    typealias GADBannerViewResult = (Result<[GADCustomNativeAd], Error>) -> ()
    private var completion: GADBannerViewResult?
    private var adLoader: GADAdLoader!
    private var customNativeAds: [GADCustomNativeAd] = []
    
    private let rootViewController: UIViewController
    private let adFormatIDs: [String]
    private let adUnitID: String
    private let customTargeting: [String: String]?
    
    init(rootViewController: UIViewController, adFormatIDs: [String], adUnitID: String, customTargeting: [String : String]?) {
        self.rootViewController = rootViewController
        self.adFormatIDs = adFormatIDs
        self.adUnitID = adUnitID
        self.customTargeting = customTargeting
    }
    
    func load(completion: @escaping GADBannerViewResult) {
        self.completion = completion
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: rootViewController,
                               adTypes: [GADAdLoaderAdType.customNative],
                               options: [])
        adLoader.delegate = self
        let adRequest = GAMRequest()
        adRequest.customTargeting = customTargeting
        adLoader.load(adRequest)
    }
}

extension TSAdManagerLoader : GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return adFormatIDs
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        print(String(describing: type(of: self)) + " adLoader:didReceive: \(customNativeAd)")
        customNativeAds.append(customNativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " adLoader:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print(String(describing: type(of: self)) + " adLoaderDidFinishLoading")
        completion?(.success(customNativeAds))
    }
}
