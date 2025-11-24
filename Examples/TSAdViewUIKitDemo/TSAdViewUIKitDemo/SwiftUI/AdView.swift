//
//  AdView.swift
//  TSAdViewUIKitDemo
//
//  Created by TAE SU LEE on 2023/07/20.
//

import TSAdView
import SwiftUI

struct AdView: View {
    var body: some View {
        TSAdViewSwiftUI(
            adServiceTypes: [
                .googleAdManager(params: .init(adFormatIDs: ["Your adFormatIDs"],
                                               adUnitIDs: ["Your adUnitID"])),
                .googleAdMob(params: .init(adDimension: CGSize(width: 300, height: 400)))
            ],
            adViewProvider: { ads, adServiceType in
                return UIImageView(image: ads.first?.image(forKey: "image")?.image)
            },
            onAdLoadSuccess: {
                print("AdView onAdLoadSuccess")
            },
            onAdLoadFailure: { error in
                print("AdView onAdLoadFailure: \(error.localizedDescription)")
            }
        )
        .frame(width: 300, height: 400)
    }
}

struct AdView_Previews: PreviewProvider {
    static var previews: some View {
        AdView()
    }
}
