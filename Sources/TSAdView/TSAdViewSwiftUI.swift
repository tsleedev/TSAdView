//
//  TSAdViewSwiftUI.swift
//
//
//  Created by TAE SU LEE on 2023/07/20.
//

import SwiftUI

/// A SwiftUI wrapper for TSAdView that handles loading and displaying ads.
public struct TSAdViewSwiftUI: UIViewRepresentable {
    private let adServiceTypes: [TSAdServiceType]
    private let adManagerViewBuilder: TSAdView.AdManagerViewBuilder?
    private let loadingIndicatorStyle: LoadingIndicatorStyle
    private let onAdLoadSuccess: ((TSAdServiceType) -> Void)?
    private let onAdLoadFailure: ((Error) -> Void)?

    /// Creates a new TSAdViewSwiftUI instance.
    /// - Parameters:
    ///   - adServiceTypes: Array of ad service types to try loading, in order of priority.
    ///   - adManagerViewBuilder: A closure that builds a custom view for Google Ad Manager ads.
    ///                           Only called for Ad Manager, not for AdMob.
    ///   - loadingIndicatorStyle: The style of loading indicator to display. Defaults to `.default`.
    ///   - onAdLoadSuccess: Called when an ad loads successfully, with the type of ad that loaded.
    ///   - onAdLoadFailure: Called when all ad types fail to load, with the error.
    public init(
        adServiceTypes: [TSAdServiceType],
        adManagerViewBuilder: TSAdView.AdManagerViewBuilder? = nil,
        loadingIndicatorStyle: LoadingIndicatorStyle = .default,
        onAdLoadSuccess: ((TSAdServiceType) -> Void)? = nil,
        onAdLoadFailure: ((Error) -> Void)? = nil
    ) {
        self.adServiceTypes = adServiceTypes
        self.adManagerViewBuilder = adManagerViewBuilder
        self.loadingIndicatorStyle = loadingIndicatorStyle
        self.onAdLoadSuccess = onAdLoadSuccess
        self.onAdLoadFailure = onAdLoadFailure
    }

    public func makeUIView(context: Context) -> TSAdView {
        let view = TSAdView(
            with: adServiceTypes,
            adManagerViewBuilder: adManagerViewBuilder,
            loadingIndicatorStyle: loadingIndicatorStyle
        )
        Task {
            do {
                let (_, adType) = try await view.loadAd()
                onAdLoadSuccess?(adType)
            } catch {
                onAdLoadFailure?(error)
            }
        }
        return view
    }

    public func updateUIView(_ uiView: TSAdView, context: Context) {
    }
}
