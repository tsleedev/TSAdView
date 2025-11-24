//
//  TSAdCoordinator.swift
//
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit
import GoogleMobileAds

public enum TSAdResult {
    case googleAdManager(ads: [CustomNativeAd], type: TSAdServiceType)
    case googleAdMob(bannerView: BannerView, type: TSAdServiceType)
}

final class TSAdCoordinator {
    private var googleAdManagerLoaders: [TSAdManagerLoader] = []
    private var adMobLoader: TSAdMobLoader?

    func loadAd(with types: [TSAdServiceType]) async throws -> TSAdResult {
        var lastError: Error?

        for type in types {
            do {
                switch type {
                case .googleAdManager(let params):
                    let ads = try await loadGoogleAdManager(with: params)
                    return .googleAdManager(ads: ads, type: type)

                case .googleAdMob(let params):
                    let bannerView = try await loadGoogleAdMob(with: params)
                    return .googleAdMob(bannerView: bannerView, type: type)
                }
            } catch {
                print("TSAdCoordinator: Failed to load \(type), trying next...")
                lastError = error
                continue
            }
        }

        throw lastError ?? NSError(domain: "TSAdCoordinator", code: 0, userInfo: [NSLocalizedDescriptionKey: "No ad types provided"])
    }
}

// MARK: - Helper
private extension TSAdCoordinator {
    func loadGoogleAdManager(with params: TSAdManagerParams) async throws -> [CustomNativeAd] {
        var allAds: [CustomNativeAd] = []

        for adUnitID in params.adUnitIDs {
            let loader = TSAdManagerLoader(
                rootViewController: params.parentViewController,
                adFormatIDs: params.adFormatIDs,
                adUnitID: adUnitID,
                customTargeting: params.customTargeting
            )
            googleAdManagerLoaders.append(loader)

            do {
                let ads = try await loader.load()
                allAds.append(contentsOf: ads)
            } catch {
                print("TSAdCoordinator: AdManager loader failed for \(adUnitID): \(error.localizedDescription)")
            }
        }

        guard !allAds.isEmpty else {
            throw NSError(domain: "TSAdCoordinator", code: 0, userInfo: [NSLocalizedDescriptionKey: "No ads found from Google Ad Manager"])
        }

        return allAds
    }

    @MainActor
    func loadGoogleAdMob(with params: TSAdMobParams) async throws -> BannerView {
        let loader = TSAdMobLoader()
        adMobLoader = loader

        return try await loader.load(
            rootViewController: params.parentViewController,
            adUnitID: params.adUnitID,
            adDimension: params.adDimension
        )
    }
}
