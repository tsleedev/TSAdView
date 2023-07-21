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

swift // let package = Package( // ... // dependencies: [ // .package(url: "https://github.com/tsleedev/TSAdView.git", from: "0.1.0"), // ], // ... // ) //

Replace USERNAME with your GitHub username.

## Usage

### Import the TSAdView module

Add the following import to the top of the file:

swift // import TSAdView //

### Initialize and load the Ad view

Here's an example for how to use it:

swift // func loadAd() { // let types: [TSAdServiceType] = [ // .googleAdManager(params: .init(parentViewController: self, // adUnitID: (/*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/)), // .googleAdMob(params: .init(parentViewController: self, // adUnitID: (/*@START_MENU_TOKEN@*/"Your adUnitID"/*@END_MENU_TOKEN@*/, // adDimension: CGSize(width: 300, height: 400))) // ] // let adView = TSAdView(with: types) { [weak self] ad in // guard let self = self else { return UIView() } // return self.adManagerAdView(ad) // } // adView.load() // self.adContainerView.addSubview(adView) // adView.translatesAutoresizingMaskIntoConstraints = false // NSLayoutConstraint.activate([ // adView.topAnchor.constraint(equalTo: self.adContainerView.topAnchor), // adView.bottomAnchor.constraint(equalTo: self.adContainerView.bottomAnchor), // adView.leadingAnchor.constraint(equalTo: self.adContainerView.leadingAnchor), // adView.trailingAnchor.constraint(equalTo: self.adContainerView.trailingAnchor) // ]) // } //

## Author

tsleedev, your-email@example.com

## License

TSAdView is available under the MIT license. See the LICENSE file for more info.
