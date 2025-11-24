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

    private var customNativeAd1: CustomNativeAd?
    private var customNativeAd2: CustomNativeAd?

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            await requestConsentAndLoadAds()
        }
    }
}

// MARK: - AdLoad
private extension AdMultiViewController {
    func requestConsentAndLoadAds() async {
        do {
            if !TSAdConsentManager.shared.canRequestAds {
                try await TSAdConsentManager.shared.requestConsentUpdate(from: self)
            }

            guard TSAdConsentManager.shared.canRequestAds else {
                print("Cannot request ads due to consent status")
                return
            }

            await loadAllAds()
        } catch {
            print("Failed to obtain consent: \(error.localizedDescription)")
        }
    }

    func loadAllAds() async {
        async let ad1: Void = loadAd(for: adViewContainer1) { [weak self] customNativeAd in
            self?.customNativeAd1 = customNativeAd
        }
        async let ad2: Void = loadAd(for: adViewContainer2) { [weak self] customNativeAd in
            self?.customNativeAd2 = customNativeAd
        }
        _ = await (ad1, ad2)
    }

    func loadAd(for container: UIView, completion: @escaping (CustomNativeAd?) -> Void) async {
        let types: [TSAdServiceType] = [
            .googleAdManager(params: .init(viewController: self,
                                           adFormatIDs: ["Your adFormatIDs"],
                                           adUnitIDs: ["Your adUnitID"])),
            .googleAdMob(params: .init(viewController: self,
                                       adDimension: CGSize(width: UIScreen.main.bounds.width, height: 50)))
        ]

        let adView = TSAdView(with: types, adManagerViewBuilder: { ads, adServiceType in
            let customNativeAd = ads.first
            completion(customNativeAd)
            return UIImageView(image: customNativeAd?.image(forKey: "image")?.image)
        })

        container.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: container.topAnchor),
            adView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        do {
            _ = try await adView.loadAd()
            print("Ad loaded successfully")
        } catch {
            print("Failed to load ad: \(error.localizedDescription)")
            completion(nil)
        }
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
