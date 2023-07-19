//
//  TSAdManager.swift
//  
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit

public final class TSAdManager {
    private let adLoading: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.color = .gray
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    private var adMobBanners: [TSAdMobBanner] = []
    
    public init() { }
    
    public func load(with type: TSAdServiceType, completion: @escaping (UIView?) -> ()) {
        switch type {
        case .googleAdManager:
            completion(nil)
        case .googleAdMob(let params):
            let adMobBanner = TSAdMobBanner()
            adMobBanners.append(adMobBanner)
            adMobBanner.load(rootViewController: params.parentViewController,
                             adUnitID: params.adUnitID,
                             adDimension: params.adDimension) {
                switch $0 {
                case .success(let view):
                    completion(view)
                case .failure:
                    completion(nil)
                }
            }
        }
    }
}
