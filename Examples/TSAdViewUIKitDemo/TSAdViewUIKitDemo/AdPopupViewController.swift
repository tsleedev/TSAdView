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
                                           adFormatIDs: ["Your adFormatIDs"],
                                           adUnitIDs: ["Your adUnitID"])),
            .googleAdMob(params: .init(viewController: self,
                                       adDimension: CGSize(width: 300, height: 400)))
        ]

        let adView = TSAdView(with: types, adManagerViewBuilder: { [weak self] ads in
            self?.closeButton.isHidden = true
            return UIImageView(image: ads.first?.image(forKey: "image")?.image)
        })
        adView.indicatorColor = .white

        adViewContainer.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: adViewContainer.topAnchor),
            adView.bottomAnchor.constraint(equalTo: adViewContainer.bottomAnchor),
            adView.leadingAnchor.constraint(equalTo: adViewContainer.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: adViewContainer.trailingAnchor)
        ])

        Task {
            do {
                let (_, adType) = try await adView.loadAd()
                closeButton.isHidden = false
                print("AdPopupViewController ad loaded successfully: \(adType)")
            } catch {
                print("AdPopupViewController onAdLoadFailure: \(error.localizedDescription)")
                presentingViewController?.dismiss(animated: true)
            }
        }
    }
}

// MARK: - IBAction
private extension AdPopupViewController {
    @IBAction func close(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true)
    }
}
