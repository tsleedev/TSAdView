//
//  TSAdManagerLoader.swift
//  
//
//  Created by TAE SU LEE on 2023/07/20.
//

import Foundation
import GoogleMobileAds

class TSAdManagerLoader: NSObject {
    typealias GADBannerViewResult = Result<[GADCustomNativeAd], Error>
    private var completion: ((GADBannerViewResult) -> ())?
    
    private var adLoader: GADAdLoader!
    private var customNativeAds: [GADCustomNativeAd] = []
    
    func load(rootViewController: UIViewController, adUnitID: String, completion: @escaping (GADBannerViewResult) -> ()) {
        self.completion = completion
//        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
//        multipleAdsOptions.numberOfAds = 1
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: rootViewController,
                               adTypes: [GADAdLoaderAdType.customNative],
                               options: [])
        adLoader.delegate = self
        let adRequest = GAMRequest()
//        adRequest.customTargeting = UserViewModel.shared.customTargeting
        adLoader.load(adRequest)
    }
}

extension TSAdManagerLoader : GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return ["11888177", "11887920", "11946351"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        print(String(describing: type(of: self)) + " adLoader:didReceive: \(customNativeAd)")
        self.customNativeAds.append(customNativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " adLoader:didFailToReceiveAdWithError: \(error.localizedDescription)")
        completion?(.failure(error))
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print(String(describing: type(of: self)) + " adLoaderDidFinishLoading")
        completion?(.success(customNativeAds))
    }
}
