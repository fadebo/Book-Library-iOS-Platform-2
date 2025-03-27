//
//  BookmarkController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-16.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class BookmarkController: UIViewController {
    
    // MARK: - Variables
    private var bookmarkedBooks: [BookmarkedBook] = []
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookmarkTableViewCell.self, forCellReuseIdentifier: BookmarkTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bookmark"
        self.view.backgroundColor = .systemBackground
        setupUI()
        fetchBookmarkedBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBookmarkedBooks()
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
    private func fetchBookmarkedBooks() {
        guard let user = Auth.auth().currentUser else {
            // Handle case where user is not logged in
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("students").document(user.uid)
        
        userRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching bookmarks: \(error)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let bookmarks = data["bookmarks"] as? [String] else {
                return
            }
            
            self?.fetchBookDetails(bookKeys: bookmarks)
        }
    }

    private func fetchBookDetails(bookKeys: [String]) {
        let group = DispatchGroup()
        var books: [BookmarkedBook] = []
        
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
                        
                        let book = BookmarkedBook(key: key, title: title, description: description, dateCreated: dateCreated ?? "Unknown Date", authorKey: authorKey, image: image)
                        books.append(book)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            self.bookmarkedBooks = books
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
    @objc private func removeBookmark(_ sender: UIButton) {
        let index = sender.tag
        let bookKey = bookmarkedBooks[index].key

        guard let user = Auth.auth().currentUser else {
            // Handle case where user is not logged in
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("students").document(user.uid)
        
        userRef.updateData([
            "bookmarks": FieldValue.arrayRemove([bookKey])
        ]) { [weak self] error in
            if let error = error {
                print("Error removing bookmark: \(error)")
                return
            }
            
            self?.bookmarkedBooks.remove(at: index)
            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}

// MARK: - UITableViewDataSource
extension BookmarkController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkTableViewCell.reuseIdentifier, for: indexPath) as? BookmarkTableViewCell else {
            fatalError("Unable to dequeue BookmarkTableViewCell")
        }
        let book = bookmarkedBooks[indexPath.row]
        cell.configure(with: book)
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeBookmark(_:)), for: .touchUpInside)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BookmarkController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = bookmarkedBooks[indexPath.row]
        let detailsController = DetailsController()
        detailsController.bookKey = selectedBook.key
        navigationController?.pushViewController(detailsController, animated: true)
    }
}

// MARK: - BookmarkedBook Model
struct BookmarkedBook {
    let key: String
    let title: String
    let description: String
    let dateCreated: String
    let authorKey: String
    let image: UIImage?
}

// MARK: - BookmarkTableViewCell
class BookmarkTableViewCell: UITableViewCell {
    static let reuseIdentifier = "BookmarkTableViewCell"
    
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
    
    let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        button.tintColor = .red
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
        contentView.addSubview(removeButton)
        
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bookImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor, multiplier: 0.7),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: bookImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            authorLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            removeButton.widthAnchor.constraint(equalToConstant: 30),
            removeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with book: BookmarkedBook) {
        bookImageView.image = book.image
        titleLabel.text = book.title
        descriptionLabel.text = book.description
        dateLabel.text = book.dateCreated
        authorLabel.text = book.authorKey
        authorLabel.text = "Loading author..."
        fetchAuthorName(authorKey: book.authorKey)
    }
    
    private func fetchAuthorName(authorKey: String) {
           guard let url = URL(string: "https://openlibrary.org\(authorKey).json") else { return }
           print(authorKey)
           URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               guard let data = data, error == nil else { return }
               do {
                   if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let authorName = jsonResult["name"] as? String {
                       DispatchQueue.main.async {
                           self?.authorLabel.text = authorName
                           print(authorName)
                       }
                   }
               } catch {
                   print("Error fetching author name: \(error)")
               }
           }.resume()
       }
}

extension String {
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: self) else { return self }
        
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK: - UIImageView Extension
//extension UIImageView {
//    func loadImageFromUrl(_ urlString: String) {
//        guard let url = URL(string: urlString) else { return }
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            DispatchQueue.main.async {
//                self.image = UIImage(data: data)
//            }
//        }.resume()
//    }
//}

// MARK: - UIImage Extension
extension UIImage {
    static func loadImageFromUrl(_ urlString: String) -> UIImage? {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
