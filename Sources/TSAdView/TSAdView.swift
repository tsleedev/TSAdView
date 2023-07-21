//
//  TSAdView.swift
//  
//
//  Created by TAE SU LEE on 2023/07/20.
//

import UIKit
import GoogleMobileAds

public class TSAdView: UIView {
    public typealias AdViewProvider = (GADCustomNativeAd) -> UIView?
    
    private let adLoading: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.tintColor = .white
        indicatorView.hidesWhenStopped = true
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    private let adManager = TSAdManager()
    private let types: [TSAdServiceType]
    private let adViewProvider: AdViewProvider
    
    public init(with types: [TSAdServiceType], adViewProvider: @escaping AdViewProvider) {
        self.types = types
        self.adViewProvider = adViewProvider
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func load() {
        adManager.load(with: types) { [weak self] customNativeAd, bannerView  in
            guard let self = self else { return }
            var adView: UIView?
            if let customNativeAd = customNativeAd {
                adView = self.adViewProvider(customNativeAd)
            } else if let view = bannerView {
                adView = view
            }
            guard let adView = adView else { return }
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
