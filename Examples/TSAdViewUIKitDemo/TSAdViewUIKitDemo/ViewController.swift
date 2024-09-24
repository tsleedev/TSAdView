//
//  ViewController.swift
//  TSAdViewUIKitDemo
//
//  Created by TAE SU LEE on 2023/07/19.
//

import TSAdView
import UIKit

struct TableViewItem {
    let title: String
    let action: () -> Void
}

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }
    
    var items: [TableViewItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TSAdView Example"
        
        items = [
            TableViewItem(title: "Show AdPopup", action: { [weak self] in
                self?.performSegue(withIdentifier: "AdPopup", sender: self)
            }),
            TableViewItem(title: "Show AdLottie", action: { [weak self] in
                self?.performSegue(withIdentifier: "AdLottie", sender: self)
            }),
            TableViewItem(title: "Show Ad with SwiftUI", action: { [weak self] in
                self?.navigationController?.pushViewController(AdViewController(), animated: true)
            })
        ]
        
        TSAdConsentManager.shared.resetConsentInformation()
        
        // 디버그 설정 활성화
        let debugSettings = TSAdConsentDebugSettings(
            testDeviceIdentifiers: ["YOUR_TEST_DEVICE_IDENTIFIER"],
            geography: .EEA
        )
        TSAdConsentManager.shared.setDebugSettings(debugSettings)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].action()
    }
}
