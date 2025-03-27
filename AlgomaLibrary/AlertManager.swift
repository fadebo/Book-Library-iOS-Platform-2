//
//  AlertManager.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-16.
//

import UIKit

class AlertManager {
    public static func showBasicAlert(on vc: UIViewController, title: String, message: String?) {
        
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            
            vc.present(alert, animated: true)
        }
        
        
    }
}

// MARK: - Show Validation Alerta

extension AlertManager {

    public static func showInvalidEmailAlert(on vc: UIViewController, message: String) {
        self.showBasicAlert(on: vc, title: "Invalid Email", message: message)
    }

    public static func showInvalidPasswordAlert(on vc: UIViewController, message: String) {
        self.showBasicAlert(on: vc, title: "Invalid Password", message: message)
    }

    public static func showInvalidUsernameAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Username", message: "Please enter a valid username.")
    }

    public static func showInvalidConfirmPasswordAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Invalid Password", message: "Passwords do not match.")
    }
}


// MARK: - Registration errors

extension AlertManager {
    
    public static func showRegistrationErrorAlert(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Unknown Registration Error", message: "nil")
    }
    
    public static func showRegistrationErrorAlert(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Unknown Registration Error", message: "\(error.localizedDescription)")
    }
    
}

// MARK: - Log in errors

extension AlertManager {
    
    public static func showLoginErrorAlert(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Unknown Error Logging In", message: "nil")
    }
    
    public static func showLoginErrorAlert(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Error Logging In", message: "\(error.localizedDescription)")
    }
    
}

// MARK: - Log out  errors

extension AlertManager {
    
    public static func showLogoutErrorAlert(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Unknown Error Logging Out", message: "\(error.localizedDescription)")
    }
    
}

// MARK: - Forgot password errors

extension AlertManager {
    
    public static func showPasswordResetSent(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Successful", message: "Password Reset Sent")
    }
    
    public static func showResetPasswordErrorAlert(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Error Sending Password Reset", message: "\(error.localizedDescription)")
    }
    
}

// MARK: - Verification errors

extension AlertManager {
    
    public static func showEmailVerificationSent(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Successful", message: "Verification email sent.")
    }
    
    public static func showEmailVerificationSent(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Error Sending Email Verification", message: "\(error.localizedDescription)")
    }
    
}
// MARK: - Fetching User errors

extension AlertManager {
    
    public static func showUnkownFetchingUserError(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Unknown Error Fetching User", message: "nil")
    }
    
    public static func showFetchingUserError(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Error Fetching User", message: "\(error.localizedDescription)")
    }
    
}

// MARK: - Edit Profile errors

extension AlertManager {
    
    public static func showEditProfileSuccessAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, title: "Success", message: "Profile updated successfully.")

        }

    public static func showEditProfileErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, title: "Error", message: "\(error.localizedDescription)")
    }
}


