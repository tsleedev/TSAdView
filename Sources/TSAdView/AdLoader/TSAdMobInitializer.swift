//
//  TSAdMobInitializer.swift
//
//
//  Created by TAE SU LEE on 2026/07/06.
//

import GoogleMobileAds

/// Ensures MobileAds.shared.start is called only once across all loaders.
@MainActor
enum TSAdMobInitializer {
    private static var isStarted = false

    static func startIfNeeded() {
        guard !isStarted else { return }
        MobileAds.shared.start(completionHandler: nil)
        isStarted = true
    }
}
