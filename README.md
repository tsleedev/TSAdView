# TSAdView

A Swift library for loading ads from multiple ad networks (Google Ad Manager, AdMob) with ease using modern async/await patterns.

## Features

- Support for Google Ad Manager and Google AdMob
- Automatic fallback to next ad network on failure
- GDPR consent management (UserMessagingPlatform)
- UIKit and SwiftUI support
- Modern Swift Concurrency (async/await)
- Swift 6 ready

## Requirements

- iOS 13.0+
- Xcode 16+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
.package(url: "https://github.com/tsleedev/TSAdView.git", .upToNextMajor(from: "1.1.0"))
```

Or add it through Xcode: File → Add Package Dependencies → Enter the repository URL.

## Usage

### Import

```swift
import TSAdView
```

### UIKit

```swift
func loadAd() {
    let types: [TSAdServiceType] = [
        .googleAdManager(params: .init(viewController: self,
                                       adFormatIDs: ["Your adFormatID"],
                                       adUnitIDs: ["Your adUnitID"])),
        .googleAdMob(params: .init(viewController: self,
                                   adDimension: CGSize(width: 300, height: 250)))
    ]

    let adView = TSAdView(with: types, adManagerViewBuilder: { ads in
        // Return custom UIView for Google Ad Manager
        // For AdMob, this closure is not called (BannerView is used automatically)
        return UIImageView(image: ads.first?.image(forKey: "image")?.image)
    })

    // Add to view hierarchy
    view.addSubview(adView)
    adView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        adView.topAnchor.constraint(equalTo: view.topAnchor),
        adView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        adView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        adView.heightAnchor.constraint(equalToConstant: 250)
    ])

    // Load ad using async/await
    Task {
        do {
            let (_, adType) = try await adView.loadAd()
            print("Ad loaded successfully: \(adType)")
        } catch {
            print("Failed to load ad: \(error.localizedDescription)")
        }
    }
}
```

### SwiftUI

```swift
import TSAdView
import SwiftUI

struct ContentView: View {
    var body: some View {
        TSAdViewSwiftUI(
            adServiceTypes: [
                .googleAdManager(params: .init(adFormatIDs: ["Your adFormatID"],
                                               adUnitIDs: ["Your adUnitID"])),
                .googleAdMob(params: .init(adDimension: CGSize(width: 300, height: 250)))
            ],
            adManagerViewBuilder: { ads in
                return UIImageView(image: ads.first?.image(forKey: "image")?.image)
            },
            onAdLoadSuccess: { adType in
                print("Ad loaded successfully: \(adType)")
            },
            onAdLoadFailure: { error in
                print("Failed to load ad: \(error.localizedDescription)")
            }
        )
        .frame(width: 300, height: 250)
    }
}
```

## Example

To run the example project, open `Examples/TSAdViewUIKitDemo/TSAdViewUIKitDemo.xcodeproj` in Xcode.

## Author

tslee, tslee.dev@gmail.com

## License

TSAdView is available under the MIT license. See the LICENSE file for more info.
