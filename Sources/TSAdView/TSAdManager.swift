//
//  TSAdManager.swift
//  
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit
import GoogleMobileAds

final class TSAdManager {
    typealias AdManagerProvider = (GADCustomNativeAd?, GADBannerView?) -> ()
    
    private lazy var adManagerLoader = TSAdManagerLoader()
    private lazy var adMobLoader = TSAdMobLoader()
    
    public func load(with types: [TSAdServiceType], completion: @escaping AdManagerProvider) {
        guard let type = types.first else {
            completion(nil, nil)
            return
        }
        
        let remainingTypes = Array(types.dropFirst())
        
        switch type {
        case .googleAdManager(let params):
            adManagerLoader.load(rootViewController: params.parentViewController,
                                 adUnitID: params.adUnitID) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let customNativeAds):
                    completion(customNativeAds.first, nil)
                case .failure:
                    self.load(with: remainingTypes, completion: completion)
                }
            }
        case .googleAdMob(let params):
            adMobLoader.load(rootViewController: params.parentViewController,
                             adUnitID: params.adUnitID,
                             adDimension: params.adDimension) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let view):
                    completion(nil, view)
                case .failure:
                    self.load(with: remainingTypes, completion: completion)
                }
            }
        }
    }
}
