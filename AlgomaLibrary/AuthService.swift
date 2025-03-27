//
//  AuthService.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-01.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AuthService {
    public static let shared = AuthService()
    public init() {}
    
    // MARK: - User Registration
    
    public func registerUser(with userRequest: RegisterUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        let username = userRequest.username
        let email = userRequest.email
        let password = userRequest.password
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                // User already exists in Authentication, but might not be in Firestore
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        completion(false, error)
                        return
                    }
                    
                    guard let resultUser = authResult?.user else {
                        completion(false, nil)
                        return
                    }
                    
                    self.addUserToFirestore(resultUser, username: username, email: email, completion: completion)
                }
                return
            }
            
            guard let resultUser = result?.user else {
                completion(false, nil)
                return
            }
            
            self.addUserToFirestore(resultUser, username: username, email: email, completion: completion)
        }
    }

    private func addUserToFirestore(_ resultUser: FirebaseAuth.User, username: String, email: String, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "username": username,
            "name": "",
            "email": email,
            "isEmailVerified": false,
            "signature": "",
            "profilePictureURL": "",
            "friendList": [],
            "bookmarks": [],
            "loanedBooks": [],
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("students").document(resultUser.uid).setData(userData) { error in
            if let error = error {
                completion(false, error)
                return
            }
            
            self.sendVerificationEmail(to: resultUser) { success in
                completion(success, nil)
            }
        }
    }
    
    // MARK: - Email Verification
    
    public func sendVerificationEmail(to user: FirebaseAuth.User, completion: @escaping (Bool) -> Void) {
        user.sendEmailVerification { error in
            completion(error == nil)
        }
    }
    
    // MARK: - User Sign In
    
    public func signIn(with userRequest: LoginUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        
        let email = userRequest.email
        let password = userRequest.password
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    // MARK: - Sign Out

    public func signOut(completion: @escaping (Bool, Error?) -> Void) {
           do {
               try Auth.auth().signOut()
               completion(true, nil)
           } catch let signOutError as NSError {
               print("Error signing out: %@", signOutError)
               completion(false, signOutError)
           }
       }

    
    // MARK: - Password Reset
    
    public func resetPassword(for email: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error == nil, error)
        }
    }
    // MARK: - View Profile
    

    // MARK: - Profile Management
    
    public func updateProfile(username: String? = nil, signature: String? = nil, profileImage: UIImage? = nil, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        var updateData: [String: Any] = [:]
        
        if let username = username {
            updateData["username"] = username
        }
        
        if let signature = signature {
            updateData["signature"] = signature
        }
        
        let updateClosure = { [weak self] in
            db.collection("students").document(userId).updateData(updateData) { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
        
        if let profileImage = profileImage {
            self.uploadProfileImage(profileImage) { result in
                switch result {
                case .success(let url):
                    updateData["profilePictureURL"] = url.absoluteString
                    updateClosure()
                case .failure(let error):
                    completion(false, error)
                }
            }
        } else {
            updateClosure()
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }
    }
    
    // MARK: - Change Password
    
    public func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, Error?) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion(false, NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
                return
            }
            
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
            
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                user.updatePassword(to: newPassword) { error in
                    completion(error == nil, error)
                }
            }
        }
    
    // MARK: - Delete Account
    func deleteUser(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completion(false, error)
                return
            }

            guard let user = Auth.auth().currentUser else {
                completion(false, NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
                return
            }

            user.delete { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

}
