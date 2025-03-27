//
//  LoanedBooksController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoanedBooksController: UIViewController {
    
    // MARK: - Variables
    private var loanedBooks: [LoanedBook] = []
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LoanedBookTableViewCell.self, forCellReuseIdentifier: LoanedBookTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Loaned Books"
        self.view.backgroundColor = .systemBackground
        setupUI()
        fetchLoanedBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLoanedBooks()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    private func fetchLoanedBooks() {
        guard let user = Auth.auth().currentUser else {
            // Handle case where user is not logged in
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("students").document(user.uid)
        
        userRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching loaned books: \(error)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let loanedBooks = data["loanedBooks"] as? [String] else {
                return
            }
            
            self?.fetchBookDetails(bookKeys: loanedBooks)
        }
    }

    private func fetchBookDetails(bookKeys: [String]) {
        let group = DispatchGroup()
        var books: [LoanedBook] = []
        
        for key in bookKeys {
            group.enter()
            
            let urlString = "https://openlibrary.org\(key).json"
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching book details: \(error)")
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        let title = json["title"] as? String ?? "Unknown Title"
                        let description = json["description"] as? String ?? "No description available"
                        let dateCreated = self?.formatDate(from: json["created"] as? [String: Any])
                        let authorKey = (json["authors"] as? [[String: Any]])?.first?["key"] as? String ?? ""
                        
                        var image: UIImage? = nil
                        if let coverId = (json["covers"] as? [Int])?.first {
                            image = UIImage.loadImageFromUrl("https://covers.openlibrary.org/b/id/\(coverId)-M.jpg")
                        }
                        
                        let book = LoanedBook(key: key, title: title, description: description, dateCreated: dateCreated ?? "Unknown Date", authorKey: authorKey, image: image)
                        books.append(book)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            self.loanedBooks = books
            self.tableView.reloadData()
        }
    }

    private func formatDate(from createdDict: [String: Any]?) -> String {
        guard let createdValue = createdDict?["value"] as? String else {
            return "Unknown Date"
        }

        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFractionalSeconds]
        
        if let date = inputFormatter.date(from: createdValue) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM, yyyy"
            return outputFormatter.string(from: date)
        } else {
            return "Unknown Date"
        }
    }
    
    // MARK: - Actions
    @objc private func returnBook(_ sender: UIButton) {
        let index = sender.tag
        let book = loanedBooks[index]

        guard let user = Auth.auth().currentUser else {
            // Handle case where user is not logged in
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("students").document(user.uid)
        
        userRef.updateData([
            "loanedBooks": FieldValue.arrayRemove([book.key])
        ]) { [weak self] error in
            if let error = error {
                AlertManager.showBasicAlert(on: self!, title: "Error", message: "Failed to return book: \(error.localizedDescription)")
                return
            }
            
            self?.loanedBooks.remove(at: index)
            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            AlertManager.showBasicAlert(on: self!, title: "Success", message: "Book returned successfully.")
        }
    }

    @objc private func extendBook(_ sender: UIButton) {
        let index = sender.tag
        let book = loanedBooks[index]

        AlertManager.showBasicAlert(on: self, title: "\(book.title) Extension Request Sent", message: "Your extension request for \(book.title) has been successfully submitted. Please visit the nearest Algomau Library to complete the validation process.")
    }
    
    
}

// MARK: - UITableViewDataSource
extension LoanedBooksController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loanedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LoanedBookTableViewCell.reuseIdentifier, for: indexPath) as? LoanedBookTableViewCell else {
            fatalError("Unable to dequeue LoanedBookTableViewCell")
            }
        let book = loanedBooks[indexPath.row]
        cell.configure(with: book)
        cell.returnButton.tag = indexPath.row
        cell.extendButton.tag = indexPath.row
        cell.returnButton.addTarget(self, action: #selector(returnBook(_:)), for: .touchUpInside)
        cell.extendButton.addTarget(self, action: #selector(extendBook(_:)), for: .touchUpInside)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LoanedBooksController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = loanedBooks[indexPath.row]
        let detailsController = DetailsController()
        detailsController.bookKey = selectedBook.key
        navigationController?.pushViewController(detailsController, animated: true)
    }
}

// MARK: - LoanedBook Model
struct LoanedBook {
    let key: String
    let title: String
    let description: String
    let dateCreated: String
    let authorKey: String
    let image: UIImage?
}

// MARK: - LoanedBookTableViewCell
class LoanedBookTableViewCell: UITableViewCell {
    static let reuseIdentifier = "LoanedBookTableViewCell"
    
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textColor = .gray
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Return", for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    let extendButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Extend", for: .normal)
            button.tintColor = .systemGreen
            return button
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(bookImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(returnButton)
        contentView.addSubview(extendButton)
        
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        extendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bookImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor, multiplier: 0.7),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: returnButton.leadingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            authorLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            returnButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            returnButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            returnButton.widthAnchor.constraint(equalToConstant: 60),
            returnButton.heightAnchor.constraint(equalToConstant: 30),
            
            extendButton.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 10),
            extendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            extendButton.widthAnchor.constraint(equalToConstant: 60),
            extendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with book: LoanedBook) {
        bookImageView.image = book.image
        titleLabel.text = book.title
        descriptionLabel.text = book.description
        dateLabel.text = book.dateCreated
        authorLabel.text = "Loading author..."
        fetchAuthorName(authorKey: book.authorKey)
    }

    private func fetchAuthorName(authorKey: String) {
        guard let url = URL(string: "https://openlibrary.org\(authorKey).json") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let authorName = jsonResult["name"] as? String {
                    DispatchQueue.main.async {
                        self?.authorLabel.text = authorName
                    }
                }
            } catch {
                print("Error fetching author name: \(error)")
            }
        }.resume()
    }
}
