//
//  WebViewController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-15.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private let url: URL
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        loadWebPage()
    }
    
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        self.view.addSubview(webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    private func loadWebPage() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func didTapDone() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Web view started loading a page
        // Show loading indicators or perform setup
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Web view finished loading a page successfully
        // Hide loading indicators or perform post-loading tasks
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Web view failed to load a page due to an error
        // Handle the error (e.g., display an error message)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Decide whether to allow or cancel the navigation action
        // You can inspect navigationAction.request and make a decision
        // For example, you can check if it's a link click and open it in Safari instead
        decisionHandler(.allow) // Allow the navigation
    }
}
