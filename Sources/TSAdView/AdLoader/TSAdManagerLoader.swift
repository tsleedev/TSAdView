//
//  TSAdManagerLoader.swift
//  
//
//  Created by TAE SU LEE on 2023/07/20.
//

import Foundation
import Combine
import GoogleMobileAds

class TSAdManagerLoader: NSObject {
    private var customNativeAdsSubject = PassthroughSubject<[CustomNativeAd], Never>()
    var customNativeAdsPublisher: AnyPublisher<[CustomNativeAd], Never> {
        customNativeAdsSubject.eraseToAnyPublisher()
    }
    
    private var adLoader: AdLoader!
    private var customNativeAds: [CustomNativeAd] = []
    
    private let rootViewController: UIViewController
    private let adFormatIDs: [String]
    private let adUnitID: String
    private let customTargeting: [String: String]?
    
    init(rootViewController: UIViewController, adFormatIDs: [String], adUnitID: String, customTargeting: [String : String]?) {
        self.rootViewController = rootViewController
        self.adFormatIDs = adFormatIDs
        self.adUnitID = adUnitID
        self.customTargeting = customTargeting
        super.init()
        load()
    }
    
    private func load() {
        let multipleAdsOptions = MultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 1
        adLoader = AdLoader(adUnitID: adUnitID,
                            rootViewController: rootViewController,
                            adTypes: [AdLoaderAdType.customNative],
                            options: [])
        adLoader.delegate = self
        let adRequest = AdManagerRequest()
        adRequest.customTargeting = customTargeting
        adLoader.load(adRequest)
    }
}

extension TSAdManagerLoader : CustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: AdLoader) -> [String] {
        return adFormatIDs
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive customNativeAd: CustomNativeAd) {
        print(String(describing: type(of: self)) + " adLoader:didReceive: \(customNativeAd)")
        customNativeAds.append(customNativeAd)
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print(String(describing: type(of: self)) + " adLoader:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        print(String(describing: type(of: self)) + " adLoaderDidFinishLoading")
        customNativeAdsSubject.send(customNativeAds)
        customNativeAdsSubject.send(completion: .finished)
    }
}
