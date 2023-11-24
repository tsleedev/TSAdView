//
//  AdPopupViewController.swift
//  TSAdViewUIKitDemo
//
//  Created by TAE SU LEE on 2023/07/21.
//

import TSAdView
import UIKit

class AdPopupViewController: UIViewController {
    @IBOutlet private weak var adViewContainer: UIView!
    @IBOutlet private weak var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.isHidden = true
        adLoad()
    }
}

// MARK: - AdLoad
private extension AdPopupViewController {
    func adLoad() {
        let types: [TSAdServiceType] = [
            .googleAdManager(params: .init(viewController: self,
                                           adFormatIDs: [/*@START_MENU_TOKEN@*/"Your adFormatIDs"/*@END_MENU_TOKEN@*/],
                                           adUnitIDs: [/*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/])),
            .googleAdMob(params: .init(viewController: self,
//                                       adUnitID: /*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/,
                                       adDimension: CGSize(width: 300, height: 400)))
        ]
        let adView = TSAdView(with: types, adViewProvider: { [weak self] ads, adServiceType in
            // Create and return your custom UIView here based on the `ad`.
            // Note: This closure is specifically designed for AdManager.
            // For AdMob, you don't need to provide a custom UIView.
            self?.closeButton.isHidden = true
            return UIImageView(image: ads.first?.image(forKey: "image")?.image)
        }, onAdMobLoadSuccess: { [weak self] in
            print("AdPopupViewController onAdMobLoadSuccess")
            self?.closeButton.isHidden = false
        }, onAdLoadFailure: { [weak self] in
            print("AdPopupViewController onAdLoadFailure")
            self?.presentingViewController?.dismiss(animated: true)
        })
        adView.loadAd()
        adView.adIndicatorColor = .white
        adViewContainer.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: adViewContainer.topAnchor),
            adView.bottomAnchor.constraint(equalTo: adViewContainer.bottomAnchor),
            adView.leadingAnchor.constraint(equalTo: adViewContainer.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: adViewContainer.trailingAnchor)
        ])
    }
}

// MARK: - IBAction
private extension AdPopupViewController {
    @IBAction func close(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true)
    }
}
