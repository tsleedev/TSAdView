//
//  TSAdView.swift
//
//
//  Created by TAE SU LEE on 2023/07/20.
//

import UIKit
import GoogleMobileAds

/// A UIView subclass that handles loading and displaying ads from Google Ad Manager and AdMob.
public class TSAdView: UIView {
    /// A closure that builds a custom UIView from Google Ad Manager's CustomNativeAd data.
    /// This closure is only called for Google Ad Manager ads, not for AdMob.
    /// - Parameter ads: Array of CustomNativeAd objects containing ad data (images, text, JSON, etc.)
    /// - Returns: A custom UIView to display the ad, or nil if the view cannot be created.
    public typealias AdManagerViewBuilder = ([CustomNativeAd]) -> UIView?

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()

    private let adCoordinator = TSAdCoordinator()
    private let types: [TSAdServiceType]
    private let adManagerViewBuilder: AdManagerViewBuilder?

    /// The color of the loading indicator.
    public var indicatorColor: UIColor? {
        get { loadingIndicator.color }
        set { loadingIndicator.color = newValue }
    }

    /// Creates a new TSAdView instance.
    /// - Parameters:
    ///   - types: Array of ad service types to try loading, in order of priority.
    ///   - adManagerViewBuilder: A closure that builds a custom view for Google Ad Manager ads.
    ///                           Required if using Google Ad Manager, ignored for AdMob.
    public init(with types: [TSAdServiceType], adManagerViewBuilder: AdManagerViewBuilder? = nil) {
        self.types = types
        self.adManagerViewBuilder = adManagerViewBuilder
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Loads and displays an ad asynchronously.
    /// - Returns: The UIView displaying the ad (either custom view for Ad Manager or BannerView for AdMob).
    /// - Throws: An error if all ad types fail to load or if AdManagerViewBuilder returns nil.
    @MainActor
    public func loadAd() async throws -> (UIView, TSAdServiceType) {
        defer { loadingIndicator.stopAnimating() }

        let result = try await adCoordinator.loadAd(with: types)

        let adView: UIView
        let adType: TSAdServiceType
        switch result {
        case .googleAdManager(let ads, let type):
            guard let customView = adManagerViewBuilder?(ads) else {
                throw NSError(domain: "TSAdView", code: 0, userInfo: [NSLocalizedDescriptionKey: "AdManagerViewBuilder returned nil"])
            }
            adView = customView
            adType = type

        case .googleAdMob(let bannerView, let type):
            adView = bannerView
            adType = type
        }

        displayAdView(adView)
        return (adView, adType)
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
