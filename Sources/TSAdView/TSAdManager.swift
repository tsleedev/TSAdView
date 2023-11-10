//
//  TSAdManager.swift
//  
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit
import Combine
import GoogleMobileAds

final class TSAdManager {
    typealias AdManagerProvider = ([GADCustomNativeAd]?, GADBannerView?) -> ()
    
    private lazy var adManagerLoaders = [TSAdManagerLoader]()
    private lazy var adMobLoader = TSAdMobLoader()
    private var cancellables: Set<AnyCancellable> = []
    
    func loadAd(with types: [TSAdServiceType], completion: @escaping AdManagerProvider) {
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
                    self.loadAd(with: remainingTypes, completion: completion)
                }
            }
        case .googleAdMob(let params):
            loadGoogleAdMob(with: params) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let view):
                    completion(nil, view)
                case .failure:
                    self.loadAd(with: remainingTypes, completion: completion)
                }
            }
        }
    }
}

// MARK: - Helper
private extension TSAdManager {
    func loadGoogleAdManager(with params: TSAdManagerParams, completion: @escaping (Result<[GADCustomNativeAd], Error>) -> ()) {
        var results = [Int: GADCustomNativeAd]()
        let serialQueue = DispatchQueue(label: "com.tsleedev.TSAdView.googleAdManagerSaverQueue")
        
        let publishers = params.adUnitIDs.enumerated().map { [weak self] index, adUnitID -> AnyPublisher<(Int, GADCustomNativeAd), Never> in
            guard let self = self else { return Empty<(Int, GADCustomNativeAd), Never>().eraseToAnyPublisher() }
            let adManagerLoader = TSAdManagerLoader(rootViewController: params.parentViewController,
                                                    adFormatIDs: params.adFormatIDs,
                                                    adUnitID: adUnitID,
                                                    customTargeting: params.customTargeting)
            self.adManagerLoaders.append(adManagerLoader)
            return adManagerLoader.customNativeAdsPublisher
                .compactMap { $0.first }
                .map { ad in (index, ad) }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .sink { _ in
                let sortedKeys = results.keys.sorted(by: <)
                var orderedResults: [GADCustomNativeAd] = []
                sortedKeys.forEach { key in
                    if let banner = results[key] {
                        orderedResults.append(banner)
                    }
                }
                
                if orderedResults.isEmpty {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No Ads Found"])
                    completion(.failure(error))
                } else {
                    completion(.success(orderedResults))
                }
            } receiveValue: { indexedAds in
                indexedAds.forEach { index, ad in
                    serialQueue.sync {
                        results[index] = ad
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func loadGoogleAdMob(with params: TSAdMobParams, completion: @escaping (Result<GADBannerView, Error>) -> ()) {
        adMobLoader.load(rootViewController: params.parentViewController,
                         adUnitID: params.adUnitID,
                         adDimension: params.adDimension)
        
        adMobLoader.bannerViewPublisher
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            } receiveValue: { view in
                completion(.success(view))
            }
            .store(in: &cancellables)
    }
}
