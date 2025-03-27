//
//  EditProfileController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol EditProfileControllerDelegate: AnyObject {
    func didUpdateUserProfile()
    func didSelectProfileImage(_ image: UIImage)
}

class EditProfileController: UIViewController, ProfileImageSelectionDelegate {
    weak var delegate: EditProfileControllerDelegate?
    // MARK: - Variables
    private var user: User

    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()

    private static func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }

    private let nameLabel = createLabel(withText: "Name")
    private let userNameLabel = createLabel(withText: "Username")
    private let emailLabel = createLabel(withText: "Email")
    private let signatureLabel = createLabel(withText: "Signature")
    
    private let nameTextField = CustomTextField(fieldType: .name)
    private let userNameTextField = CustomTextField(fieldType: .username)
    private let emailTextField = CustomTextField(fieldType: .email)
    private let signatureTextField = CustomTextField(fieldType: .signature)
    private let saveButton = CustomButton(title: "Save Changes", hasBackground: true, fontSize: .mid)

    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
        populateUserData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Edit Profile"

        self.view.addSubview(profileImageView)
        self.view.addSubview(cameraButton)
        self.view.addSubview(nameLabel)
        self.view.addSubview(nameTextField)
        self.view.addSubview(userNameLabel)
        self.view.addSubview(userNameTextField)
        self.view.addSubview(emailLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(verifyButton)
        self.view.addSubview(signatureLabel)
        self.view.addSubview(signatureTextField)
        self.view.addSubview(saveButton)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        signatureLabel.translatesAutoresizingMaskIntoConstraints = false
        signatureTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.profileImageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.profileImageView.widthAnchor.constraint(equalToConstant: 100),
            self.profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            self.cameraButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            self.cameraButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            self.cameraButton.widthAnchor.constraint(equalToConstant: 44),
            self.cameraButton.heightAnchor.constraint(equalToConstant: 44),
            
            self.nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            self.nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            self.nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            self.nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.nameTextField.heightAnchor.constraint(equalToConstant: 55),
            self.nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.userNameLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            self.userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            self.userNameTextField.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 20),
            self.userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.userNameTextField.heightAnchor.constraint(equalToConstant: 55),
            self.userNameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.emailLabel.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 10),
            self.emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            self.emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            self.emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.emailTextField.heightAnchor.constraint(equalToConstant: 55),
            self.emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.verifyButton.centerYAnchor.constraint(equalTo: emailTextField.centerYAnchor),
            self.verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -43),
            self.verifyButton.widthAnchor.constraint(equalToConstant: 60),
            
            self.signatureLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            self.signatureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            self.signatureTextField.topAnchor.constraint(equalTo: signatureLabel.bottomAnchor, constant: 20),
            self.signatureTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.signatureTextField.heightAnchor.constraint(equalToConstant: 55),
            self.signatureTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.saveButton.topAnchor.constraint(equalTo: signatureTextField.bottomAnchor, constant: 33),
            self.saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.saveButton.heightAnchor.constraint(equalToConstant: 55),
            self.saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])

        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    private func populateUserData() {
        profileImageView.image = user.profileImage
        nameTextField.text = user.name
        userNameTextField.text = user.username
        emailTextField.text = user.email
        emailTextField.isEnabled = false // Prevent email editing
        signatureTextField.text = user.signature

        // Check if email is verified
        if user.isEmailVerified {
            verifyButton.isHidden = true
        } else {
            verifyButton.isHidden = false
        }
    }

    // MARK: - Actions
    @objc private func cameraButtonTapped() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.sourceType = .photoLibrary
//        imagePickerController.delegate = self
//        present(imagePickerController, animated: true, completion: nil)
        let imageSelectionVC = ProfileImageSelectionViewController()
            imageSelectionVC.delegate = self
            imageSelectionVC.modalPresentationStyle = .custom
            imageSelectionVC.transitioningDelegate = self
            present(imageSelectionVC, animated: true, completion: nil)
    }
    // MARK: - ProfileImageSelectionDelegate
        func didSelectProfileImage(_ image: UIImage) {
            profileImageView.image = image
        }
    @objc private func verifyButtonTapped() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showEmailVerificationSent(on: self, with: error)
                return
            }
            
            AlertManager.showEmailVerificationSent(on: self)
        })
    }

    @objc private func saveButtonTapped() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Prepare user data
        let updatedUser = User(
            name: nameTextField.text ?? "",
            email: user.email, // Email should not be updated
            username: userNameTextField.text,
            signature: signatureTextField.text,
            isEmailVerified: user.isEmailVerified,
            profileImage: profileImageView.image // This remains unchanged
        )
        
        // Check if there is a new profile image to upload
        if let profileImage = profileImageView.image, let imageData = profileImage.jpegData(compressionQuality: 0.75) {
            let storageRef = Storage.storage().reference().child("profileImages/\(userID).jpg")
            
            // Upload image data to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
                guard let self = self else { return }
                if let error = error {
                    AlertManager.showEditProfileErrorAlert(on: self, with: error)
                    return
                }
                
                // Get the download URL
                storageRef.downloadURL { [weak self] url, error in
                    guard let self = self else { return }
                    if let error = error {
                        AlertManager.showEditProfileErrorAlert(on: self, with: error)
                        return
                    }
                    
                    // Update Firestore document with new image URL
                    let imageUrl = url?.absoluteString ?? ""
                    self.updateFirestore(with: updatedUser, imageUrl: imageUrl)
                }
            }
        } else {
            // No new image, just update Firestore
            updateFirestore(with: updatedUser, imageUrl: nil)
        }
    }

    private func updateFirestore(with user: User, imageUrl: String?) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        var userData: [String: Any] = [
            "name": user.name,
            "username": user.username as Any,
            "signature": user.signature as Any
        ]
        
        if let imageUrl = imageUrl {
            userData["profilePictureURL"] = imageUrl
        }
        
        db.collection("students").document(userID).setData(userData, merge: true) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showEditProfileErrorAlert(on: self, with: error)
            } else {
                AlertManager.showEditProfileSuccessAlert(on: self)
                self.delegate?.didUpdateUserProfile()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        profileImageView.image = selectedImage
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension EditProfileController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

