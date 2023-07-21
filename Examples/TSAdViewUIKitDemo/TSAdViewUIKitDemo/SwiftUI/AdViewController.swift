//
//  AdViewController.swift
//  TSAdViewUIKitDemo
//
//  Created by TAE SU LEE on 2023/07/20.
//

import UIKit
import SwiftUI

class AdViewController: UIViewController {
    // MARK: - Views
    private lazy var hostingView: UIView = {
        addChild(hostingController)
        return hostingController.view
    }()
    
    // MARK: - Properties
    private let hostingController: UIHostingController<AnyView>
    private let rootView: AdView
    
    // MARK: - Initialize with ViewModel
    init() {
        self.rootView = AdView()
        self.hostingController = UIHostingController(rootView: AnyView(rootView))
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
}

// MARK: - Setup
private extension AdViewController {
    func setupViews() {
        view.addSubview(hostingView)
    }
    
    func setupConstraints() {
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
