//
//  FriendsViewController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-17.
//

import UIKit

class FriendsViewController: UIViewController {
    // MARK: - Variables
    private var user: User

    // MARK: - UI Components

    private static func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }

    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Friends"


        self.view.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            

        ])
    }

//    private func populateUserData() {
//        oldPasswordTextField.text = user.name
//    }



}
