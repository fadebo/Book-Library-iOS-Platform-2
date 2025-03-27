//
//  ChangePasswordViewController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-17.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
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
    private let currentPasswordLabel = createLabel(withText: "Current Password")
    private let passwordLabel = createLabel(withText: "New Password")
    private let confirmPasswordLabel = createLabel(withText: "Confirm Password")
    
    private let currentPasswordTextField = CustomTextField(fieldType: .password)
    private let passwordTextField = CustomTextField(fieldType: .password)
    private let confirmPasswordTextField = CustomTextField(fieldType: .confirmPassword)
    private let saveButton = CustomButton(title: "Save Changes", hasBackground: true, fontSize: .mid)

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
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Change Password"

        view.addSubview(currentPasswordLabel)
        view.addSubview(currentPasswordTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordLabel)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(saveButton)
        
        currentPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        currentPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentPasswordLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            currentPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            currentPasswordTextField.topAnchor.constraint(equalTo: currentPasswordLabel.bottomAnchor, constant: 20),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: 55),
            currentPasswordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            passwordLabel.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 10),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 55),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 55),
            confirmPasswordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            saveButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 33),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
    }

    @objc private func saveButtonTapped() {
        guard let currentPassword = currentPasswordTextField.text, !currentPassword.isEmpty,
              let newPassword = passwordTextField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            AlertManager.showInvalidPasswordAlert(on: self, message: "Please fill in all fields.")
            return
        }

        // Validate new password
        if !Validator.isPasswordValid(for: newPassword) {
            AlertManager.showInvalidPasswordAlert(on: self, message: "New password does not meet criteria.")
            return
        }

        // Check if new password and confirm password match
        if newPassword != confirmPassword {
            AlertManager.showInvalidConfirmPasswordAlert(on: self)
            return
        }

        // Call AuthService to change password
        AuthService().changePassword(currentPassword: currentPassword, newPassword: newPassword) { [weak self] success, error in
            if success {
                AlertManager.showBasicAlert(on: self!, title: "Success", message: "Password changed successfully.")
                self?.navigationController?.popViewController(animated: true)
            } else {
                if let authError = error as NSError? {
                    switch authError.code {
                    case AuthErrorCode.wrongPassword.rawValue:
                        AlertManager.showInvalidPasswordAlert(on: self!, message: "Current password is incorrect.")
                    case AuthErrorCode.credentialAlreadyInUse.rawValue:
                        AlertManager.showInvalidPasswordAlert(on: self!, message: "Credential is already in use.")
                    case AuthErrorCode.userNotFound.rawValue:
                        AlertManager.showInvalidPasswordAlert(on: self!, message: "User not found.")
                    default:
                        AlertManager.showLoginErrorAlert(on: self!, with: error!)
                    }
                } else {
                    AlertManager.showLoginErrorAlert(on: self!, with: error!)
                }
            }
        }
    }
}
