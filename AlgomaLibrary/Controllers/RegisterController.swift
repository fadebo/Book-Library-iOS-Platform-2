//
//  RegisterController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-01.
//

import UIKit

class RegisterController: UIViewController, UITextViewDelegate {
    
    // MARK: - UI Components
    private let headerView = AuthHeaderView(title: "Welcome to Algoma Library", subTitle: "Create an account to access the Library from anywhere at anytime")
    private let usernameField = CustomTextField(fieldType: .username)
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    private let confirmPasswordField = CustomTextField(fieldType: .confirmPassword)
    
    private let signUpButton = CustomButton(title: "Sign Up", hasBackground: true, fontSize: .big)
    private let loginButton = CustomButton(title: "Already have an account? Login now.", hasBackground: false, fontSize: .mid)
    
    private let termsTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .label
        tv.isSelectable = true
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.dataDetectorTypes = .link
        
        let termsText = "By Creating an account, you agree to our "
        let linkText = "Terms & conditions"
        let privacyText = " and you acknowledge that you have read our "
        let priLinkText = "Privacy Policy"
        let fullText = termsText + linkText + privacyText + priLinkText
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.link, value: "https://algomau.ca/about/", range: NSRange(location: termsText.count, length: linkText.count))
        attributedString.addAttribute(.link, value: "https://algomau.ca/privacy-policy/", range: NSRange(location: termsText.count + linkText.count + privacyText.count, length: priLinkText.count))
        tv.attributedText = attributedString
        return tv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        // Set the delegate for termsTextView
        self.termsTextView.delegate = self
        
        // Do any additional setup after loading the view.
        self.signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        self.loginButton.addTarget(self, action: #selector(didTapLogIn), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(headerView)
        self.view.addSubview(usernameField)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(confirmPasswordField)
        self.view.addSubview(termsTextView)
        self.view.addSubview(loginButton)
        self.view.addSubview(signUpButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),
            
            self.usernameField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 25),
            self.usernameField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.usernameField.heightAnchor.constraint(equalToConstant: 55),
            self.usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 12),
            self.emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.emailField.heightAnchor.constraint(equalToConstant: 55),
            self.emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: 55),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 12),
            self.confirmPasswordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.confirmPasswordField.heightAnchor.constraint(equalToConstant: 55),
            self.confirmPasswordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.termsTextView.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 6),
            self.termsTextView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.termsTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.signUpButton.topAnchor.constraint(equalTo: termsTextView.bottomAnchor, constant: 11),
            self.signUpButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signUpButton.heightAnchor.constraint(equalToConstant: 44),
            self.signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.loginButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 17),
            self.loginButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.loginButton.heightAnchor.constraint(equalToConstant: 55),
            self.loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let webVC = WebViewController(with: URL)
        present(webVC, animated: true, completion: nil)
        return false
    }
    
    // MARK: - Selectors
    @objc private func didTapSignUp() {
        let username = self.usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = self.emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = self.passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPassword = self.confirmPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Check if any field is empty
        if username.isEmpty {
            AlertManager.showInvalidUsernameAlert(on: self)
            return
        }
        
        if email.isEmpty {
            AlertManager.showInvalidEmailAlert(on: self, message: "Email cannot be empty.")
            return
        }
        
        if password.isEmpty {
            AlertManager.showInvalidPasswordAlert(on: self, message: "Password cannot be empty.")
            return
        }
        
        if confirmPassword.isEmpty {
            AlertManager.showInvalidConfirmPasswordAlert(on: self)
            return
        }

        // Username check
        if !Validator.isVAlidUsername(for: username) {
            AlertManager.showInvalidUsernameAlert(on: self)
            return
        }

        // Email check
        if !Validator.isValidEmail(for: email) {
            AlertManager.showInvalidEmailAlert(on: self, message: "Please enter a valid student email (example@algomau.ca).")
            return
        }

        // Password check
        if !Validator.isPasswordValid(for: password) {
            AlertManager.showInvalidPasswordAlert(on: self, message: "Password must be 6-32 characters long, contain at least one lowercase letter, one uppercase letter, one number, and one special character.")
            return
        }

        // Confirm password check
        if password != confirmPassword {
            AlertManager.showInvalidConfirmPasswordAlert(on: self)
            return
        }

        // Proceed with registration
        AuthService.shared.registerUser(with: RegisterUserRequest(username: username, email: email, password: password, confirmPassword: confirmPassword)) { wasRegistered, error in
            if let error = error {
                // Handle registration error
                AlertManager.showRegistrationErrorAlert(on: self, with: error)
                return
            }
            
            if wasRegistered {
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuthentication()
                }
            } else {
                AlertManager.showRegistrationErrorAlert(on: self)
            }
        }
    }
    
    @objc private func didTapLogIn() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
