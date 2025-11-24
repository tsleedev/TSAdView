//
//  TSAdViewSwiftUI.swift
//
//
//  Created by TAE SU LEE on 2023/07/20.
//

import SwiftUI

public struct TSAdViewSwiftUI: UIViewRepresentable {
    private let adServiceTypes: [TSAdServiceType]
    private let adManagerViewBuilder: TSAdView.AdManagerViewBuilder?
    private let onAdLoadSuccess: (() -> Void)?
    private let onAdLoadFailure: ((Error) -> Void)?

    public init(
        adServiceTypes: [TSAdServiceType],
        adManagerViewBuilder: TSAdView.AdManagerViewBuilder? = nil,
        onAdLoadSuccess: (() -> Void)? = nil,
        onAdLoadFailure: ((Error) -> Void)? = nil
    ) {
        self.adServiceTypes = adServiceTypes
        self.adManagerViewBuilder = adManagerViewBuilder
        self.onAdLoadSuccess = onAdLoadSuccess
        self.onAdLoadFailure = onAdLoadFailure
    }

    public func makeUIView(context: Context) -> TSAdView {
        let view = TSAdView(with: adServiceTypes, adManagerViewBuilder: adManagerViewBuilder)
        Task {
            do {
                _ = try await view.loadAd()
                onAdLoadSuccess?()
            } catch {
                onAdLoadFailure?(error)
            }
        }
        return view
    }

    public func updateUIView(_ uiView: TSAdView, context: Context) {
    }
}
