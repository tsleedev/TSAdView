//
//  AdMultiViewController.swift
//  TSAdViewUIKitDemo
//
//  Created by TAE SU LEE on 9/25/24.
//

import TSAdView
import UIKit
import GoogleMobileAds

class AdMultiViewController: UIViewController {
    @IBOutlet private weak var adViewContainer1: UIView!
    @IBOutlet private weak var adViewContainer2: UIView!
    
    private var customNativeAd1: GADCustomNativeAd?
    private var customNativeAd2: GADCustomNativeAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestConsentAndLoadAds()
    }
}

// MARK: - AdLoad
private extension AdMultiViewController {
    func requestConsentAndLoadAds() {
        if TSAdConsentManager.shared.canRequestAds {
            self.loadAllAds()
        } else {
            TSAdConsentManager.shared.requestConsentUpdate(from: self) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Failed to obtain consent: \(error.localizedDescription)")
                    // Handle error (e.g., show an alert to the user)
                    return
                }
                
                if TSAdConsentManager.shared.canRequestAds {
                    self.loadAllAds()
                } else {
                    print("Cannot request ads due to consent status")
                    // Handle the case where ads cannot be shown
                }
            }
        }
    }
    
    func loadAllAds() {
        loadAd(for: adViewContainer1, completion: { [weak self] customNativeAd in
            self?.customNativeAd1 = customNativeAd
        })
        loadAd(for: adViewContainer2, completion: { [weak self] customNativeAd in
            self?.customNativeAd2 = customNativeAd
        })
    }
    
    func loadAd(for container: UIView, completion: @escaping (GADCustomNativeAd?) -> Void) {
        let types: [TSAdServiceType] = [
            .googleAdManager(params: .init(viewController: self,
                                           adFormatIDs: ["Your adFormatIDs"],
                                           adUnitIDs: ["Your adUnitID"])),
            .googleAdMob(params: .init(viewController: self,
                                       adDimension: CGSize(width: UIScreen.main.bounds.width, height: 50)))
        ]
        
        let adView = TSAdView(with: types, adViewProvider: { ads, adServiceType in
            let customNativeAd = ads.first
            completion(customNativeAd)
            return UIImageView(image: customNativeAd?.image(forKey: "image")?.image)
        }, onAdMobLoadSuccess: {
            print("Ad loaded successfully")
        }, onAdLoadFailure: {
            print("Failed to load ad")
            completion(nil)
        })
        
        adView.loadAd()
        container.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: container.topAnchor),
            adView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
}

// MARK: - IBAction
private extension AdMultiViewController {
    @IBAction func clickAd1(_ sender: UIButton) {
        customNativeAd1?.performClickOnAsset(withKey: "json")
    }
    
    @IBAction func clickAd2(_ sender: UIButton) {
        customNativeAd2?.performClickOnAsset(withKey: "json")
    }
}
