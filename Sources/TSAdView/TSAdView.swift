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

    /// A closure that builds a NativeAdView template from AdMob's NativeAd data.
    /// This closure is only called for AdMob native ads.
    /// The app is responsible for creating the template and connecting asset views
    /// (headlineView, mediaView, callToActionView, etc.). Assigning `nativeAdView.nativeAd`
    /// can be omitted — TSAdView performs the assignment last, which registers
    /// impression/click tracking in the order recommended by the SDK.
    /// If no `adChoicesView` is connected, the SDK renders the AdChoices icon automatically.
    /// - Parameter nativeAd: The loaded NativeAd containing ad assets.
    /// - Returns: A NativeAdView to display the ad, or nil if the view cannot be created.
    public typealias AdMobNativeViewBuilder = (NativeAd) -> NativeAdView?

    private var loadingIndicatorView: UIView?

    private let adCoordinator = TSAdCoordinator()
    private let types: [TSAdServiceType]
    private let adManagerViewBuilder: AdManagerViewBuilder?
    private let adMobNativeViewBuilder: AdMobNativeViewBuilder?
    private let loadingIndicatorStyle: LoadingIndicatorStyle
    private var retainedNativeAd: NativeAd?

    /// The color of the loading indicator.
    @available(*, deprecated, message: "Use loadingIndicatorStyle parameter in init instead")
    public var indicatorColor: UIColor? {
        get {
            if let activityIndicator = loadingIndicatorView as? UIActivityIndicatorView {
                return activityIndicator.color
            }
            return nil
        }
        set {
            if let activityIndicator = loadingIndicatorView as? UIActivityIndicatorView {
                activityIndicator.color = newValue
            }
        }
    }

    /// Creates a new TSAdView instance.
    /// - Parameters:
    ///   - types: Array of ad service types to try loading, in order of priority.
    ///   - adManagerViewBuilder: A closure that builds a custom view for Google Ad Manager ads.
    ///                           Required if using Google Ad Manager, ignored for AdMob.
    ///   - adMobNativeViewBuilder: A closure that builds a NativeAdView template for AdMob native ads.
    ///                             Required if using AdMob native, ignored for other ad types.
    ///   - loadingIndicatorStyle: The style of loading indicator to display. Defaults to `.default`.
    public init(
        with types: [TSAdServiceType],
        adManagerViewBuilder: AdManagerViewBuilder? = nil,
        adMobNativeViewBuilder: AdMobNativeViewBuilder? = nil,
        loadingIndicatorStyle: LoadingIndicatorStyle = .default
    ) {
        self.types = types
        self.adManagerViewBuilder = adManagerViewBuilder
        self.adMobNativeViewBuilder = adMobNativeViewBuilder
        self.loadingIndicatorStyle = loadingIndicatorStyle
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Loads and displays an ad asynchronously.
    /// Types are tried in order. A type is skipped not only when loading fails,
    /// but also when its view builder returns nil (e.g. the app decides the loaded
    /// ad's assets are insufficient to render) — the next type is then requested.
    /// - Returns: The UIView displaying the ad (either custom view for Ad Manager,
    ///            BannerView for AdMob, or NativeAdView for AdMob native).
    /// - Throws: An error if all ad types fail to load or be rendered.
    @MainActor
    public func loadAd() async throws -> (UIView, TSAdServiceType) {
        defer { stopLoadingIndicator() }

        var lastError: Error?
        for type in types {
            do {
                let result = try await adCoordinator.loadAd(with: [type])
                let (adView, adType) = try makeAdView(from: result)
                displayAdView(adView)
                return (adView, adType)
            } catch {
                print("TSAdView: Failed to load or render \(type), trying next...")
                lastError = error
                continue
            }
        }

        throw lastError ?? NSError(domain: "TSAdView", code: 0, userInfo: [NSLocalizedDescriptionKey: "No ad types provided"])
    }

    @MainActor
    private func makeAdView(from result: TSAdResult) throws -> (UIView, TSAdServiceType) {
        switch result {
        case .googleAdManager(let ads, let type):
            guard let customView = adManagerViewBuilder?(ads) else {
                throw NSError(domain: "TSAdView", code: 0, userInfo: [NSLocalizedDescriptionKey: "AdManagerViewBuilder returned nil"])
            }
            return (customView, type)

        case .googleAdMob(let bannerView, let type):
            return (bannerView, type)

        case .googleAdMobNative(let nativeAd, let type):
            guard let nativeAdView = adMobNativeViewBuilder?(nativeAd) else {
                throw NSError(domain: "TSAdView", code: 0, userInfo: [NSLocalizedDescriptionKey: "AdMobNativeViewBuilder returned nil"])
            }
            // Assigning nativeAd last registers impression/click tracking after asset views are connected.
            if nativeAdView.nativeAd == nil {
                nativeAdView.nativeAd = nativeAd
            }
            retainedNativeAd = nativeAd
            return (nativeAdView, type)
        }
    }
}

// MARK: - Setup
private extension TSAdView {
    func setupViews() {
        setupLoadingIndicator()
    }

    func setupLoadingIndicator() {
        switch loadingIndicatorStyle {
        case .none:
            loadingIndicatorView = nil

        case .default:
            let indicatorView = UIActivityIndicatorView(style: .medium)
            indicatorView.hidesWhenStopped = true
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(indicatorView)
            NSLayoutConstraint.activate([
                indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
                indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            indicatorView.startAnimating()
            loadingIndicatorView = indicatorView

        case .color(let color):
            let indicatorView = UIActivityIndicatorView(style: .medium)
            indicatorView.hidesWhenStopped = true
            indicatorView.color = color
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(indicatorView)
            NSLayoutConstraint.activate([
                indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
                indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            indicatorView.startAnimating()
            loadingIndicatorView = indicatorView

        case .custom(let viewBuilder):
            let customView = viewBuilder()
            customView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(customView)
            NSLayoutConstraint.activate([
                customView.centerXAnchor.constraint(equalTo: centerXAnchor),
                customView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            loadingIndicatorView = customView
        }
    }

    func stopLoadingIndicator() {
        if let activityIndicator = loadingIndicatorView as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
        }
        loadingIndicatorView?.removeFromSuperview()
        loadingIndicatorView = nil
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
