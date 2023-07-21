//
//  TSAdServiceType.swift
//  
//
//  Created by TAE SU LEE on 2023/07/19.
//

import UIKit

public enum TSAdServiceType {
    case googleAdManager(params: TSAdManagerParams)
    case googleAdMob(params: TSAdMobParams)
}

public struct TSAdManagerParams {
    let parentViewController: UIViewController
    let adUnitID: String
    
    public init(viewController: UIViewController = UIViewController(),
                adUnitID: String) {
        self.parentViewController = viewController
        self.adUnitID = adUnitID
    }
}

public struct TSAdMobParams {
    let parentViewController: UIViewController
    let adUnitID: String
    let adDimension: CGSize
    
    public init(viewController: UIViewController = UIViewController(),
                adUnitID: String = "ca-app-pub-3940256099942544/2934735716",
                adDimension: CGSize = CGSize(width: 320, height: 50)) {
        self.parentViewController = viewController
        self.adUnitID = adUnitID
        self.adDimension = adDimension
    }
}
