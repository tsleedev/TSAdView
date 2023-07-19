//
//  ViewController.swift
//  TSAdManagerUIKitDemo
//
//  Created by TAE SU LEE on 2023/07/19.
//

import TSAdManager
import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var banner320x50: UIView!
    @IBOutlet private weak var banner300x250: UIView!
    
    private let adManager = TSAdManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let adServiceType320x50 = TSAdServiceType.googleAdMob(params: .init(viewController: self,
                                                                            adDimension: CGSize(width: 320, height: 50)))
        adManager.load(with: adServiceType320x50) { [weak self] view in
            guard let self = self else { return }
            self.banner320x50.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            if let view = view {
                self.banner320x50.addSubview(view)
            }
        }
        let adServiceType300x250 = TSAdServiceType.googleAdMob(params: .init(viewController: self,
                                                                             adDimension: CGSize(width: 300, height: 250)))
        adManager.load(with: adServiceType300x250) { [weak self] view in
            guard let self = self else { return }
            self.banner300x250.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            if let view = view {
                self.banner300x250.addSubview(view)
            }
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        return ViewController().showPreview()
    }
}

#endif
