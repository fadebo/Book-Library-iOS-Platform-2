//
//  CustomTextField.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-15.
//

import UIKit

enum FieldType {
    case name
    case username
    case email
    case signature
    case password
    case confirmPassword
}

class CustomTextField: UITextField {
    
    private let fieldType: FieldType
    private let eyeButton: UIButton = UIButton(type: .custom)
    
    init(fieldType: FieldType) {
        self.fieldType = fieldType
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.borderStyle = .roundedRect
        self.autocapitalizationType = .none
        
        switch fieldType {
        case .name:
            self.placeholder = "Name"
        case .username:
            self.placeholder = "Username"
            self.autocapitalizationType = .none
        case .email:
            self.placeholder = "Email"
            self.keyboardType = .emailAddress
            self.autocapitalizationType = .none
        case .signature:
            self.placeholder = "Will be displayed with your comment"
        case .password:
            self.placeholder = "Password"
        self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
            setupPasswordToggle()
        case .confirmPassword:
            self.placeholder = "Confirm Password"
        self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
        }
    }
    
    private func setupPasswordToggle() {
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        eyeButton.tintColor = .systemRed
        
        self.rightView = eyeButton
        self.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility() {
        self.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
    }
}
