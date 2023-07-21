//
//  SwiftUIView.swift
//  
//
//  Created by TAE SU LEE on 2023/07/20.
//

import SwiftUI

public struct TSAdViewSwiftUI: UIViewRepresentable {
    private let adServiceTypes: [TSAdServiceType]
    private let adViewProvider: TSAdView.AdViewProvider
    
    public init(adServiceTypes: [TSAdServiceType], adViewProvider: @escaping TSAdView.AdViewProvider) {
        self.adServiceTypes = adServiceTypes
        self.adViewProvider = adViewProvider
    }

    public func makeUIView(context: Context) -> TSAdView {
        let view = TSAdView(with: adServiceTypes, adViewProvider: adViewProvider)
        view.load()
        return view
    }
    
    public func updateUIView(_ uiView: TSAdView, context: Context) {
        
    }
}
