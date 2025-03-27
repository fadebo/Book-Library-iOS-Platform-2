//
//  PrivacyPolicyViewController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-19.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Privacy Policy"
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let url = URL(string: "https://algomau.ca/privacy-policy/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
