//
//  DetailsController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-16.
//

import UIKit
import NaturalLanguage
import FirebaseAuth
import FirebaseFirestore

class DetailsController: UIViewController {
    // MARK: - Variables
    var bookKey: String?
    private var currentTab: UIButton?
    
    // MARK: - UI Components
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = { 
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let tabStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let aboutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("About", for: .normal)
        button.tintColor = .systemRed
        return button
    }()

    private let authorDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Author Details", for: .normal)
        button.tintColor = .gray
        return button
    }()

    private let reviewsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reviews", for: .normal)
        button.tintColor = .gray
        return button
    }()

    private let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addToBookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Bookmark", for: .normal)
        button.tintColor = .systemRed
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loanNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loan Now", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
        fetchBookDetails()
    }
    
    // MARK: - UI Setup
    private func setupNavigationBar() {
        navigationItem.title = "Book Details"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
        backButton.tintColor = .systemRed
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backAction() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        [coverImageView, titleLabel, authorLabel, ratingLabel, genreLabel, infoStackView, tabStackView, contentScrollView, addToBookmarkButton, loanNowButton].forEach { view.addSubview($0) }
        contentScrollView.addSubview(contentView)
        [contentTitleLabel].forEach { contentView.addSubview($0) }
        
        [aboutButton, authorDetailsButton, reviewsButton].forEach { tabStackView.addArrangedSubview($0) }
        
        let languageInfo = createInfoLabel(title: "Language", value: "ENG")
        let publishedInfo = createInfoLabel(title: "Published", value: "2022")
        let pagesInfo = createInfoLabel(title: "Pages", value: "312")
        
        [languageInfo, publishedInfo, pagesInfo].forEach { infoStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            coverImageView.widthAnchor.constraint(equalToConstant: 120),
            coverImageView.heightAnchor.constraint(equalToConstant: 180),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            genreLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 8),
            genreLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoStackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tabStackView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 20),
            tabStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabStackView.heightAnchor.constraint(equalToConstant: 44),
            
            contentScrollView.topAnchor.constraint(equalTo: tabStackView.bottomAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: addToBookmarkButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
            
            contentTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            contentTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
//            contentDescriptionLabel.topAnchor.constraint(equalTo: contentTitleLabel.bottomAnchor, constant: 8),
//            contentDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            contentDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            contentDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            addToBookmarkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addToBookmarkButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addToBookmarkButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            addToBookmarkButton.heightAnchor.constraint(equalToConstant: 44),
            
            loanNowButton.bottomAnchor.constraint(equalTo: addToBookmarkButton.bottomAnchor),
            loanNowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loanNowButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            loanNowButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add target actions for tab buttons
        aboutButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        authorDetailsButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        reviewsButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        
        addToBookmarkButton.addTarget(self, action: #selector(didTapAddToBookmark), for: .touchUpInside)
        loanNowButton.addTarget(self, action: #selector(didTaploanNowButton), for: .touchUpInside)
    }
    
    
    @objc private func didTapAddToBookmark() {
        guard let user = Auth.auth().currentUser else {
            // Handle case where user is not logged in
            return
        }
        
        let bookKey = self.bookKey // Replace with actual book identifier
        print(bookKey as Any)
        let db = Firestore.firestore()
        let userRef = db.collection("students").document(user.uid)
        
        userRef.updateData([
            "bookmarks": FieldValue.arrayUnion([bookKey as Any])
        ]) { error in
            if let error = error {
                print("Error adding bookmark: \(error)")
                return
            }
            // Navigate to BookmarkController
            let bookmarkController = BookmarkController()
            self.navigationController?.pushViewController(bookmarkController, animated: true)
        }
    }
    
    @objc private func didTaploanNowButton() {
        guard let user = Auth.auth().currentUser else {
            // Handle case where user is not logged in
            return
        }
        
        let bookKey = self.bookKey // Replace with actual book identifier
        print(bookKey as Any)
        let db = Firestore.firestore()
        let userRef = db.collection("students").document(user.uid)
        
        userRef.updateData([
            "loanedBooks": FieldValue.arrayUnion([bookKey as Any])
        ]) { error in
            if let error = error {
                print("Error processing book loan: \(error)")
                return
            }
            // Navigate to LoanedBooksController
            let LoanedBooksController = LoanedBooksController()
            self.navigationController?.pushViewController(LoanedBooksController, animated: true)
        }
    }
    
    private func createInfoLabel(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = title
        titleLabel.textColor = .gray
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.text = value
        valueLabel.textColor = .black
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }
    
    // MARK: - Data Fetching
    private func fetchBookDetails() {
        let urlString = "https://openlibrary.org\(bookKey ?? "/works/OL15626917W").json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let authorsArray = json["authors"] as? [[String: Any]] {
                    let authorKeys = authorsArray.compactMap { authorDict in
                        if let author = authorDict["author"] as? [String: Any], let key = author["key"] as? String {
                            return key.replacingOccurrences(of: "/authors/", with: "")
                        }
                        return nil
                    }
                    
                    if let firstAuthorKey = authorKeys.first {
                        self?.fetchAuthorName(authorKey: firstAuthorKey)
                    }
                    
                    DispatchQueue.main.async {
                        self?.updateUI(with: json)
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func fetchAuthorName(authorKey: String) {
        guard let url = URL(string: "https://openlibrary.org/authors/\(authorKey).json") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let authorName = jsonResult["name"] as? String {
                    DispatchQueue.main.async {
                        self?.authorLabel.text = "Author: \(authorName)"
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    // MARK: - UI Update
    private func updateUI(with json: [String: Any]) {
            titleLabel.text = json["title"] as? String ?? "Title not available"
            ratingLabel.attributedText = generateRandomStarRating()
            genreLabel.text = (json["subjects"] as? [String])?.joined(separator: ", ") ?? "None"
            contentDescriptionLabel.text = (json["description"] as? String) ?? (json["first_sentence"] as? String ?? "Description not available")
            
            var createdYear: String = "Unknown"
            if let createdDict = json["created"] as? [String: Any], let createdValue = createdDict["value"] as? String {
                let components = createdValue.split(separator: "-")
                if components.count > 0 {
                    createdYear = String(components[0])
                }
            }
            
            let randomPages = Int.random(in: 100...1000)
            let language = detectLanguage(of: titleLabel.text ?? "Unknown")
            
            if let languageInfo = infoStackView.arrangedSubviews[0] as? UIStackView,
               let publishedInfo = infoStackView.arrangedSubviews[1] as? UIStackView,
               let pagesInfo = infoStackView.arrangedSubviews[2] as? UIStackView {
                (languageInfo.arrangedSubviews[1] as? UILabel)?.text = language
                (publishedInfo.arrangedSubviews[1] as? UILabel)?.text = createdYear
                (pagesInfo.arrangedSubviews[1] as? UILabel)?.text = "\(randomPages)"
            }
            
            if let coverId = (json["covers"] as? [Int])?.first {
                coverImageView.loadImageFromUrl("https://covers.openlibrary.org/b/id/\(coverId)-M.jpg")
            }
            
            updateContentForAbout()
        }
        
        // MARK: - Tab Handling
        @objc private func tabButtonTapped(_ sender: UIButton) {
            [aboutButton, authorDetailsButton, reviewsButton].forEach { $0.tintColor = .gray }
            sender.tintColor = .systemRed
            
            // Clear existing content
            contentView.subviews.forEach { $0.removeFromSuperview() }
            currentTab = sender
                
            switch sender {
            case aboutButton:
                updateContentForAbout()
            case authorDetailsButton:
                updateContentForAuthorDetails()
            case reviewsButton:
                updateContentForReviews()
            default:
                break
            }
        }
        
        private func updateContentForAbout() {
            contentTitleLabel.text = "Synopsis"
            let descriptionLabel = UILabel()
            descriptionLabel.numberOfLines = 0
            descriptionLabel.text = contentDescriptionLabel.text ?? "No synopsis available for this book."
            
            let stackView = UIStackView(arrangedSubviews: [contentTitleLabel, descriptionLabel])
            stackView.axis = .vertical
            stackView.spacing = 10
            
            contentView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        }
        
        private func updateContentForAuthorDetails() {
            contentTitleLabel.text = "Author Details"
            
            guard let authorName = authorLabel.text?.replacingOccurrences(of: "Author: ", with: "") else {
                let errorLabel = UILabel()
                errorLabel.text = "Author details not available."
                contentView.addSubview(errorLabel)
                errorLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    errorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
                ])
                return
            }
            
            let authorImageView = UIImageView()
            authorImageView.contentMode = .scaleAspectFit
            authorImageView.backgroundColor = .lightGray
            authorImageView.layer.cornerRadius = 30
            authorImageView.clipsToBounds = true
            
            let nameLabel = UILabel()
            nameLabel.text = authorName
            nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
            
            let followersLabel = UILabel()
            followersLabel.text = "65.2K Followers"
            followersLabel.font = UIFont.systemFont(ofSize: 14)
            followersLabel.textColor = .gray
            
            let followButton = UIButton(type: .system)
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = .systemRed
            followButton.setTitleColor(.white, for: .normal)
            followButton.layer.cornerRadius = 15
            
            let stackView = UIStackView(arrangedSubviews: [authorImageView, nameLabel, followersLabel, followButton])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 10 
            
            contentView.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                authorImageView.widthAnchor.constraint(equalToConstant: 60),
                authorImageView.heightAnchor.constraint(equalToConstant: 60),
                
                followButton.widthAnchor.constraint(equalToConstant: 100),
                followButton.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            // load the author's image here
            // authorImageView.loadImageFromUrl(authorImageUrl)
        }
        
    
    private func updateContentForReviews() {
        // Clear existing content
        contentView.subviews.forEach { $0.removeFromSuperview() }

        // Add title label for "Reviews"
        let titleLabel = UILabel()
        titleLabel.text = "Reviews"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(titleLabel)
        
        // Constraints for the title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Generate and add reviews
        let reviews = [
            "An amazing read! Highly recommended.",
            "Quite an insightful book, with a few slow parts.",
            "A must-read for enthusiasts. Engaging and informative.",
            "Well-written and thought-provoking.",
            "Not my favorite, but it had some good points.",
            "Not the best.",
            "Could be better."
        ]
        
        guard let attributedText = ratingLabel.attributedText else {
            contentDescriptionLabel.text = "No reviews available."
            return
        }
        
        let starString = attributedText.string
        let filledStarCount = starString.components(separatedBy: "★").count - 1
        
        let numberOfReviews = Int.random(in: 3...5)
        var reviewsText = ""
        
        for i in 1...numberOfReviews {
            let stars = String(repeating: "⭐️", count: filledStarCount)
            
            let reviewIndex: Int
            if filledStarCount >= 4 {
                reviewIndex = Int.random(in: 0...2)  // Good reviews
            } else if (3...4).contains(filledStarCount) {
                reviewIndex = Int.random(in: 1...4)  // Mixed reviews
            } else {
                reviewIndex = Int.random(in: 4...6)  // Poor reviews
            }
            
            let review = reviews[reviewIndex]
            reviewsText += "Review \(i): \(stars)\n"
            reviewsText += "\(review)\n\n"
        }
        
        let reviewsLabel = UILabel()
        reviewsLabel.numberOfLines = 0
        reviewsLabel.text = reviewsText
        contentView.addSubview(reviewsLabel)
        
        // Constraints for the reviews label
        reviewsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reviewsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            reviewsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reviewsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            reviewsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
        
        // MARK: - Helper Functions
        func generateRandomStarRating() -> NSAttributedString {
            let starCount = 5
            let filledStar = "★"
            let emptyStar = "☆"
            
            let goldColor = UIColor.systemYellow
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: goldColor,
                .font: UIFont.systemFont(ofSize: 20)
            ]
            
            let rating = Int.random(in: 1...starCount)
            let starString = String(repeating: filledStar, count: rating) + String(repeating: emptyStar, count: starCount - rating)
            
            return NSAttributedString(string: starString, attributes: attributes)
        }
        
        private func detectLanguage(of text: String) -> String {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            if let languageCode = recognizer.dominantLanguage?.rawValue {
                let locale = Locale(identifier: languageCode)
                return locale.localizedString(forLanguageCode: languageCode) ?? "Unknown"
            }
            return "Unknown"
        }
    }

    // MARK: - UIImageView Extension
    extension UIImageView {
        func loadImageFromUrl(_ urlString: String) {
            guard let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }.resume()
        }
    }
// MARK: - BookDetails Model
struct BookDetails: Codable {
    let title: String
    let authors: [Author]?
    let description: Description?
    let firstPublishDate: String?
    let covers: [Int]?
    let numberOfPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case authors
        case description
        case firstPublishDate = "first_publish_date"
        case covers
        case numberOfPages = "number_of_pages"
    }
}

struct Author: Codable {
    let name: String
}

struct Description: Codable {
    let value: String
}
