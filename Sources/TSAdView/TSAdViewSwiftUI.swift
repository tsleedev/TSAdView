//
//  TSAdViewSwiftUI.swift
//
//
//  Created by TAE SU LEE on 2023/07/20.
//

import SwiftUI

public struct TSAdViewSwiftUI: UIViewRepresentable {
    private let adServiceTypes: [TSAdServiceType]
    private let adViewProvider: TSAdView.AdViewProvider?
    private let onAdLoadSuccess: (() -> Void)?
    private let onAdLoadFailure: ((Error) -> Void)?

    public init(
        adServiceTypes: [TSAdServiceType],
        adViewProvider: TSAdView.AdViewProvider? = nil,
        onAdLoadSuccess: (() -> Void)? = nil,
        onAdLoadFailure: ((Error) -> Void)? = nil
    ) {
        self.adServiceTypes = adServiceTypes
        self.adViewProvider = adViewProvider
        self.onAdLoadSuccess = onAdLoadSuccess
        self.onAdLoadFailure = onAdLoadFailure
    }

    public func makeUIView(context: Context) -> TSAdView {
        let view = TSAdView(with: adServiceTypes, adViewProvider: adViewProvider)
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
