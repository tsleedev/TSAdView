# TSAdView

This library was created to help you load ads from multiple Ad networks with ease.

## Example

To run the example project, clone the repo, and run pod install from the Example directory first.

## Requirements
- iOS 13.0+
- Xcode 11+

## Installation

### Swift Package Manager

To use TSAdView with the Swift Package Manager, add the following to your Package.swift file.

```swift
.package(url: "https://github.com/tsleedev/TSAdView.git", .upToNextMajor(from: "0.1.0"))
```

Replace USERNAME with your GitHub username.

## Usage

### Import the TSAdView module

Add the following import to the top of the file:

```swift
import TSAdView
```

### Initialize and load the Ad view

Here's an example for how to use it:

```swift
func loadAd() {
let types: [TSAdServiceType] = [
 func adLoad() {
    let types: [TSAdServiceType] = [
        .googleAdManager(params: .init(viewController: self,
                                       adUnitID: /*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/)),
        .googleAdMob(params: .init(viewController: self,
//                                       adUnitID: /*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/,
                                   adDimension: CGSize(width: 300, height: 400)))
    ]
    let adView = TSAdView(with: types) { ad in
        // Create and return your custom UIView here based on the `ad`.
        // Note: This closure is specifically designed for AdManager.
        // For AdMob, you don't need to provide a custom UIView.
        return UIImageView(image: ad.image(forKey: "image")?.image)
    }
    adView.load()
    adViewContainer.addSubview(adView)
    adView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        adView.topAnchor.constraint(equalTo: adViewContainer.topAnchor),
        adView.bottomAnchor.constraint(equalTo: adViewContainer.bottomAnchor),
        adView.leadingAnchor.constraint(equalTo: adViewContainer.leadingAnchor),
        adView.trailingAnchor.constraint(equalTo: adViewContainer.trailingAnchor)
    ])
}
```

## Author

tslee, tslee.dev@gmail.com

## License

TSAdView is available under the MIT license. See the LICENSE file for more info.
