//
//  TSAdView.swift
//  
//
//  Created by TAE SU LEE on 2023/07/20.
//

import UIKit
import GoogleMobileAds

public class TSAdView: UIView {
    public typealias AdViewProvider = ([GADCustomNativeAd], TSAdServiceType) -> UIView?
    public typealias OnAdMobLoadSuccess = () -> Void
    public typealias OnAdLoadFailure = () -> Void
    
    private let adLoading: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    private let adManager = TSAdManager()
    private let types: [TSAdServiceType]
    private let adViewProvider: AdViewProvider?
    private let onAdMobLoadSuccess: OnAdMobLoadSuccess?
    private let onAdLoadFailure: OnAdLoadFailure?
    public var adIndicatorColor: UIColor? {
        get { adLoading.color }
        set { adLoading.color = newValue }
    }
    
    public init(with types: [TSAdServiceType], adViewProvider: AdViewProvider? = nil, onAdMobLoadSuccess: OnAdMobLoadSuccess? = nil, onAdLoadFailure: OnAdLoadFailure? = nil) {
        self.types = types
        self.adViewProvider = adViewProvider
        self.onAdMobLoadSuccess = onAdMobLoadSuccess
        self.onAdLoadFailure = onAdLoadFailure
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadAd() {
        adManager.loadAd(with: types) { [weak self] customNativeAds, bannerView, adServiceType in
            guard let self = self else { return }
            var adView: UIView?
            if let customNativeAds = customNativeAds, let adServiceType = adServiceType {
                adView = self.adViewProvider?(customNativeAds, adServiceType)
            } else if let view = bannerView {
                adView = view
                self.onAdMobLoadSuccess?()
            }
            guard let adView = adView else {
                self.onAdLoadFailure?()
                return
            }
            self.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            self.addSubview(adView)
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: self.topAnchor),
                adView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                adView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
        }
    }
}

// MARK: - Setup
private extension TSAdView {
    func setupViews() {
        addSubview(adLoading)
        NSLayoutConstraint.activate([
            adLoading.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            adLoading.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        adLoading.startAnimating()
    }
}
