//
//  TSAdManager.swift
//  
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit
import GoogleMobileAds

final class TSAdManager {
    typealias AdManagerProvider = ([GADCustomNativeAd]?, GADBannerView?) -> ()
    
    private lazy var adManagerLoaders = [TSAdManagerLoader]()
    private lazy var adMobLoader = TSAdMobLoader()
    
    public func load(with types: [TSAdServiceType], completion: @escaping AdManagerProvider) {
        guard let type = types.first else {
            completion(nil, nil)
            return
        }
        
        let remainingTypes = Array(types.dropFirst())
        
        switch type {
        case .googleAdManager(let params):
            loadGoogleAdManager(with: params) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let customNativeAds):
                    completion(customNativeAds, nil)
                case .failure:
                    self.load(with: remainingTypes, completion: completion)
                }
            }
        case .googleAdMob(let params):
            loadGoogleAdMob(with: params) { [weak self] result in
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

// MARK: - Helper
private extension TSAdManager {
    func loadGoogleAdManager(with params: TSAdManagerParams, completion: @escaping TSAdManagerLoader.GADBannerViewResult) {
        let dispatchGroup = DispatchGroup()
        var results = [GADCustomNativeAd]()
        let serialQueue = DispatchQueue(label: "com.tsleedev.TSAdView.googleAdManagerSaverQueue")

        params.adUnitIDs.forEach { adUnitID in
            dispatchGroup.enter()
            let adManagerLoader = TSAdManagerLoader(rootViewController: params.parentViewController,
                                                    adFormatIDs: params.adFormatIDs,
                                                    adUnitID: adUnitID,
                                                    customTargeting: params.customTargeting)
            adManagerLoaders.append(adManagerLoader)
            adManagerLoader.load() { result in
                switch result {
                case .success(let customNativeAds):
                    // Save your results in a thread safe manner
                    serialQueue.async {
                        if let customNativeAd = customNativeAds.first {
                            results.append(customNativeAd)
                        }
                    }
                case .failure:
                    break
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if results.isEmpty {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No Ads Found"])
                completion(.failure(error))
            } else {
                completion(.success(results))
            }
        }
    }
    
    func loadGoogleAdMob(with params: TSAdMobParams, completion: @escaping TSAdMobLoader.GADBannerViewResult) {
        adMobLoader.load(rootViewController: params.parentViewController,
                         adUnitID: params.adUnitID,
                         adDimension: params.adDimension) { result in
            switch result {
            case .success(let view):
                completion(.success(view))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
