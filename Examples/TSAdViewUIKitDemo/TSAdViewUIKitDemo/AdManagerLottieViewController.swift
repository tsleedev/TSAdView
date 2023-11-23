//
//  AdManagerLottieViewController.swift
//  TSAdViewUIKitDemo
//
//  Created by TAE SU LEE on 2023/07/21.
//

import TSAdView
import UIKit
import GoogleMobileAds
import Lottie

class AdManagerLottieViewController: UIViewController {
    @IBOutlet private weak var adViewContainer: UIView!
    
    private var customNativeAd: GADCustomNativeAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adLoad()
    }
}

// MARK: - AdLoad
private extension AdManagerLottieViewController {
    func adLoad() {
        let types: [TSAdServiceType] = [
            .googleAdManager(params: .init(viewController: self,
                                           adFormatIDs: [/*@START_MENU_TOKEN@*/"Your adFormatIDs"/*@END_MENU_TOKEN@*/],
                                           adUnitIDs: [/*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/])),
            .googleAdMob(params: .init(viewController: self,
//                                       adUnitID: /*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/,
                                       adDimension: CGSize(width: 200, height: 100)))
        ]
        let adView = TSAdView(with: types) { [weak self] ads, adServiceType in
            // Create and return your custom UIView here based on the `ad`.
            // Note: This closure is specifically designed for AdManager.
            // For AdMob, you don't need to provide a custom UIView.
            guard
                let self = self,
                let ad = ads.first
            else { return nil }
            return self.drawAd(with: ad)
        }
        adView.loadAd()
        adViewContainer.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: adViewContainer.topAnchor),
            adView.bottomAnchor.constraint(equalTo: adViewContainer.bottomAnchor),
            adView.leadingAnchor.constraint(equalTo: adViewContainer.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: adViewContainer.trailingAnchor)
        ])
    }
    
    func drawAd(with customNativeAd: GADCustomNativeAd) -> UIView? {
        self.customNativeAd = customNativeAd
        
        if let lottieJsonString = customNativeAd.string(forKey: "json"),
           let lottieJsonData = lottieJsonString.data(using: .utf8) {
            do {
                let animation = try JSONDecoder().decode(LottieAnimation.self, from: lottieJsonData)
                let lottieView = LottieAnimationView()
                lottieView.animation = animation
                lottieView.loopMode = .loop
                lottieView.play()
                customNativeAd.recordImpression()
                return lottieView
            } catch {
                print(error)
            }
        }
        return nil
    }
}

// MARK: - IBAction
private extension AdManagerLottieViewController {
    @IBAction func clickAd(_ sender: UIButton) {
        customNativeAd?.performClickOnAsset(withKey: "json")
    }
}
