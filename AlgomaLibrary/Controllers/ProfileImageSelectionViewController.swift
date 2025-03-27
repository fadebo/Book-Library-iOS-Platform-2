//
//  ProfileImageSelectionViewController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-17.
//

import UIKit

protocol ProfileImageSelectionDelegate: AnyObject {
    func didSelectProfileImage(_ image: UIImage)
}

class ProfileImageSelectionViewController: UIViewController {
    
    weak var delegate: ProfileImageSelectionDelegate?

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let selectLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Avatar Profile Picture"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avatarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 80, height: 120)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let setProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set as Profile Picture", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var avatars: [(UIImage, String)] = {
        let imageNames = ["Bookworm", "Tech-Savvy Librarian", "Young Explorer", "Artistic Reader", "History Buff", "Science Ethusiast"]
        var avatarArray: [(UIImage, String)] = []
        
        for name in imageNames {
            if let image = UIImage(named: name) {
                avatarArray.append((image, name))
            } else {
                print("Image named \(name) not found!")
                avatarArray.append((UIImage(), name)) // Use a default image
            }
        }
        return avatarArray
    }()
    
    private var selectedAvatarIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(profileImageView)
        view.addSubview(selectLabel)
        view.addSubview(avatarCollectionView)
        view.addSubview(setProfileButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            selectLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            selectLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            avatarCollectionView.topAnchor.constraint(equalTo: selectLabel.bottomAnchor, constant: 20),
            avatarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            avatarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            avatarCollectionView.bottomAnchor.constraint(equalTo: setProfileButton.topAnchor, constant: -20),
            
            setProfileButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            setProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setProfileButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            setProfileButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        setProfileButton.addTarget(self, action: #selector(setProfilePictureTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        avatarCollectionView.delegate = self
        avatarCollectionView.dataSource = self
        avatarCollectionView.register(AvatarCell.self, forCellWithReuseIdentifier: "AvatarCell")
    }
    
    @objc private func setProfilePictureTapped() {
        guard let index = selectedAvatarIndex else { return }
        delegate?.didSelectProfileImage(avatars[index].0)
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileImageSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! AvatarCell
        cell.configure(with: avatars[indexPath.item].0, label: avatars[indexPath.item].1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAvatarIndex = indexPath.item
        profileImageView.image = avatars[indexPath.item].0
    }
}

class AvatarCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemBackground
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with image: UIImage, label: String) {
        imageView.image = image
        nameLabel.text = label
    }
}
 
