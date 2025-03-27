//
//  ProfileController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-16.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileController: UIViewController, EditProfileControllerDelegate {
    // MARK: - Variables
    private var user: User?
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        loadUserData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func didUpdateUserProfile() {
        print("ProfileController: didUpdateUserProfile called")
        loadUserData() // Refresh the user data
    }
    
    func didSelectProfileImage(_ image: UIImage) {
        print("ProfileController: didSelectProfileImage called")
        profileImageView.image = image
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("students").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print("Error getting user data: \(error)")
                return
            }
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Document does not exist")
                return
            }
            
            let username = data["username"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let profileImageURL = data["profilePictureURL"] as? String ?? ""
            let emailVerified = data["isEmailVerified"] as? Bool
            let signature = data["signature"] as? String ?? ""
            
            self.user = User(name: name, email: email, username: username, signature: signature, isEmailVerified: emailVerified ?? false, profileImage: nil)
            
            if !profileImageURL.isEmpty {
                self.loadProfileImage(from: profileImageURL)
            } else {
                self.updateUI()
            }
        }
    }
    
    private func loadProfileImage(from url: String) {
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                print("Error downloading profile image: \(error)")
                self.updateUI()
                return
            }
            if let data = data {
                self.user?.profileImage = UIImage(data: data)
            }
            self.updateUI()
        }
    }
    
    private func updateUI() {
        print("ProfileController: updateUI called")
        nameLabel.text = user?.name
        emailLabel.text = user?.email
        profileImageView.image = user?.profileImage ?? UIImage(named: "profile_placeholder")
    }
    
    // MARK: - Actions
    private func showLogoutConfirmation() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Selectors
    private func performLogout() {
        // Implement logout functionality
        print("Logging out...")
        AuthService.shared.signOut { [weak self] success, error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showLogoutErrorAlert(on: self, with: error)
                return
            }
            if success {
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuthentication()
                }
            }
        }
    }

    private func navigateToEditProfile() {
        guard let user = user else { return }
        let editProfileVC = EditProfileController(user: user)
        editProfileVC.delegate = self // Set the delegate
        
        print("ProfileController: Setting delegate to EditProfileController") // Debugging log
        // Ensure that we have a navigation controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(editProfileVC, animated: true)
        } else {
            // If there's no navigation controller, present it modally
            editProfileVC.modalPresentationStyle = .fullScreen
            present(editProfileVC, animated: true, completion: nil)
        }
    }
    
    private func navigateToChangePasswordController() {
        guard let user = user else { return }
        let changePasswordVC = ChangePasswordViewController(user: user)
        
        // Ensure that we have a navigation controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(changePasswordVC, animated: true)
        } else {
            // If there's no navigation controller, present it modally
            changePasswordVC.modalPresentationStyle = .fullScreen
            present(changePasswordVC, animated: true, completion: nil)
        }
    }
    
    private func navigateToFriendsViewController() {
        guard let user = user else { return }
        let friendsVC = FriendsViewController(user: user)
        
        // Ensure that we have a navigation controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(friendsVC, animated: true)
        } else {
            // If there's no navigation controller, present it modally
            friendsVC.modalPresentationStyle = .fullScreen
            present(friendsVC, animated: true, completion: nil)
        }
    }
    
    private func navigateToLoanedBooksController() {
        guard let user = user else { return }
        let loanedBooksVC = LoanedBooksController()
        
        // Ensure that we have a navigation controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(loanedBooksVC, animated: true)
        } else {
            // If there's no navigation controller, present it modally
            loanedBooksVC.modalPresentationStyle = .fullScreen
            present(loanedBooksVC, animated: true, completion: nil)
        }
    }
    
    private func navigateToPrivacyPolicyViewController() {
        // Present Privacy Policy view controller
        let privacyPolicyVC = PrivacyPolicyViewController()
        
        // Ensure that we have a navigation controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(privacyPolicyVC, animated: true)
        } else {
            // If there's no navigation controller, present it modally
            privacyPolicyVC.modalPresentationStyle = .fullScreen
            present(privacyPolicyVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4  // Adjusted to match the number of sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 2
        case 3: return 1 // Logout Button
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.section {
        case 0:
            content.text = "Edit Profile"
            content.secondaryText = "Change profile picture, number, E-mail"
            content.image = UIImage(systemName: "person.circle")
        case 1:
            let titles = ["Change Password", "Friends", "Loaned Books"]
            let descriptions = ["Update and strengthen account security", "Check out Friends", "Manage books loaned from the library"]
            let images = ["lock.circle", "shared.with.you.circle", "books.vertical.circle"]
            content.text = titles[indexPath.row]
            content.secondaryText = descriptions[indexPath.row]
            content.image = UIImage(systemName: images[indexPath.row])
        case 2:
            let titles = ["Notification", "Privacy Policy"]
            let descriptions = ["Customize your notification preferences", "Review our policy"]
            let images = ["bell", "doc.text"]
            content.text = titles[indexPath.row]
            content.secondaryText = descriptions[indexPath.row]
            content.image = UIImage(systemName: images[indexPath.row])
        case 3:
            content.text = "Log Out"
            content.secondaryText = "Securely log out of Account"
            content.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
            content.textProperties.color = .systemRed
            cell.accessoryType = .none
        default:
            break
        }
        
        content.imageProperties.tintColor = .systemRed
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "General"
        case 1: return "Preferences"
        case 2: return "Settings"
        case 3: return nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                navigateToEditProfile()
            }
        case 1:
            if indexPath.row == 0 {
                navigateToChangePasswordController()
            }
            if indexPath.row == 1 {
                navigateToFriendsViewController()
            }
            if indexPath.row == 2 {
                navigateToLoanedBooksController()
            }
        case 2:
            if indexPath.row == 1 {
                navigateToPrivacyPolicyViewController()
            }
        case 3:
            if indexPath.row == 0 {
                showLogoutConfirmation()
            }
        default:
            break
        }
    }
}

// MARK: - User Model
struct User {
    let name: String
    let email: String
    var username: String?
    var signature: String?
    var isEmailVerified: Bool
    var profileImage: UIImage?
}
