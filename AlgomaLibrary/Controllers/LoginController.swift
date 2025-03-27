//
//  LoginController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-01.
//
import Firebase
import UIKit

class LoginController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = AuthHeaderView(title: "Welcome Back", subTitle: "Sign in to access the library")
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let loginButton = CustomButton(title: "Sign In", hasBackground: true, fontSize: .big)
    private let newUserButton = CustomButton(title: "New User? Create an Account.", hasBackground: false, fontSize: .mid)
    private let forgotPasswordButton = CustomButton(title: "Forgot Password?", fontSize: .small)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

        // Add targets for buttons
        self.loginButton.addTarget(self, action: #selector(didTapLogIn), for: .touchUpInside)
        self.newUserButton.addTarget(self, action: #selector(didTapNewUser), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(headerView)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(loginButton)
        self.view.addSubview(newUserButton)
        self.view.addSubview(forgotPasswordButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        newUserButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),
            
            self.emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            self.emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.emailField.heightAnchor.constraint(equalToConstant: 55),
            self.emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: 55),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            self.loginButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.loginButton.heightAnchor.constraint(equalToConstant: 55),
            self.loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.newUserButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 11),
            self.newUserButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.newUserButton.heightAnchor.constraint(equalToConstant: 44),
            self.newUserButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.forgotPasswordButton.topAnchor.constraint(equalTo: newUserButton.bottomAnchor, constant: 6),
            self.forgotPasswordButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.forgotPasswordButton.heightAnchor.constraint(equalToConstant: 44),
            self.forgotPasswordButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
    }
//    @objc func clearFirestoreCache() {
//        let db = Firestore.firestore()
//
//        // Set cache size to the minimum allowed value to effectively disable it
//        let settings = FirestoreSettings()
//        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 1048576) // 1 MB
//        db.settings = settings
//
//        db.clearPersistence { error in
//            if let error = error {
//                print("Error clearing Firestore cache: \(error)")
//            } else {
//                print("Firestore cache cleared successfully.")
//
//                // Fetch data from the server to ensure it's up-to-date
//                db.collection("users")
//                  .getDocuments(source: .server) { (querySnapshot, error) in
//                    if let error = error {
//                        print("Error getting documents: \(error)")
//                    } else {
//                        for document in querySnapshot!.documents {
//                            print("\(document.documentID) => \(document.data())")
//                        }
//                    }
//                }
//            }
//        }
//    }
    // MARK: - Selectors
    @objc private func didTapLogIn() {
        // Retrieve input from text fields
        let email = self.emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = self.passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Check if email and password fields are empty
        if email.isEmpty {
            AlertManager.showInvalidEmailAlert(on: self, message: "Email cannot be empty.")
            return
        }
        
        if password.isEmpty {
            AlertManager.showInvalidPasswordAlert(on: self, message: "Password cannot be empty.")
            return
        }
        
        // Email check
        if !Validator.isValidEmail(for: email) {
            AlertManager.showInvalidEmailAlert(on: self, message: "Invalid email format.")
            return
        }
        
        // Password check
        if !Validator.isPasswordValid(for: password) {
            AlertManager.showInvalidPasswordAlert(on: self, message: "Password does not meet criteria.")
            return
        }
        
        // Proceed with login
        AuthService.shared.signIn(with: LoginUserRequest(email: email, password: password)) { wasLoggedIn, error in
            if let error = error {
                // Handle login error
                AlertManager.showLoginErrorAlert(on: self, with: error)
                return
            }
            
            if wasLoggedIn {
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuthentication()
                }
            } else {
                AlertManager.showLoginErrorAlert(on: self)
            }
        }
    }
    
    @objc private func didTapNewUser() {
        let vc = RegisterController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapForgotPassword() {
        let vc = ForgotPasswordController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
