//
//  SwiftUIView.swift
//  
//
//  Created by TAE SU LEE on 2023/07/20.
//

import SwiftUI

public struct TSAdViewSwiftUI: UIViewRepresentable {
    private let adServiceTypes: [TSAdServiceType]
    private let adViewProvider: TSAdView.AdViewProvider?
    private let onAdLoadFailure: TSAdView.OnAdLoadFailure?
    
    public init(adServiceTypes: [TSAdServiceType], adViewProvider: TSAdView.AdViewProvider? = nil, onAdLoadFailure: TSAdView.OnAdLoadFailure? = nil) {
        self.adServiceTypes = adServiceTypes
        self.adViewProvider = adViewProvider
        self.onAdLoadFailure = onAdLoadFailure
    }

    public func makeUIView(context: Context) -> TSAdView {
        let view = TSAdView(with: adServiceTypes, adViewProvider: adViewProvider, onAdLoadFailure: onAdLoadFailure)
        view.loadAd()
        return view
    }
    
    public func updateUIView(_ uiView: TSAdView, context: Context) {
        
    }
}
