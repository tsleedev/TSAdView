//
//  TSAdView.swift
//
//
//  Created by TAE SU LEE on 2023/07/20.
//

import UIKit
import GoogleMobileAds

public class TSAdView: UIView {
    public typealias AdManagerViewBuilder = ([CustomNativeAd], TSAdServiceType) -> UIView?

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()

    private let adCoordinator = TSAdCoordinator()
    private let types: [TSAdServiceType]
    private let adManagerViewBuilder: AdManagerViewBuilder?

    public var indicatorColor: UIColor? {
        get { loadingIndicator.color }
        set { loadingIndicator.color = newValue }
    }

    public init(with types: [TSAdServiceType], adManagerViewBuilder: AdManagerViewBuilder? = nil) {
        self.types = types
        self.adManagerViewBuilder = adManagerViewBuilder
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    public func loadAd() async throws -> UIView {
        defer { loadingIndicator.stopAnimating() }

        let result = try await adCoordinator.loadAd(with: types)

        let adView: UIView
        switch result {
        case .googleAdManager(let ads, let type):
            guard let customView = adManagerViewBuilder?(ads, type) else {
                throw NSError(domain: "TSAdView", code: 0, userInfo: [NSLocalizedDescriptionKey: "AdManagerViewBuilder returned nil"])
            }
            adView = customView

        case .googleAdMob(let bannerView, _):
            adView = bannerView
        }

        displayAdView(adView)
        return adView
    }
}

// MARK: - Setup
private extension TSAdView {
    func setupViews() {
        addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
    }

    func displayAdView(_ adView: UIView) {
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: topAnchor),
            adView.bottomAnchor.constraint(equalTo: bottomAnchor),
            adView.leadingAnchor.constraint(equalTo: leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
