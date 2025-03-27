//
//  HomeController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-01.
//

import UIKit

// MARK: - Models

struct Book {
    let title: String
    let isbn: String?
    let key: String?
    var image: UIImage?
}

struct AllBook {
    let title: String
    let isbn: String?
    let key: String?
    var image: UIImage?
}

// MARK: - Protocols

protocol CategoryTableViewCellDelegate: AnyObject {
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelectBookAt index: Int)
}

// MARK: - HomeController

class HomeController: UIViewController, CategoryTableViewCellDelegate {
    
    
    // MARK: - Properties
    
    private var books: [Book] = []
    private var allBooks: [String: [AllBook]] = [:]
    private let categories = ["archaeology", "art", "biology", "chemistry", "fiction", "finance", "maths", "physics", "programming", "psychology", "political_science"]
    private let defaultCoverImage = UIImage(named: "default_cover")
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: BookCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let topBooksLabel: UILabel = {
        let label = UILabel()
        label.text = "Top 10 Books"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 40)
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryButtonCell.self, forCellWithReuseIdentifier: CategoryButtonCell.reuseIdentifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchBooksAndAllBooks()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Home"
        view.backgroundColor = .systemBackground
        
        view.addSubview(topBooksLabel)
        view.addSubview(collectionView)
        view.addSubview(categoriesTableView)
        view.addSubview(categoriesCollectionView)
        
        NSLayoutConstraint.activate([
            topBooksLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            topBooksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topBooksLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: topBooksLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 220),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            categoriesTableView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 20),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    
    private func fetchBooksAndAllBooks() {
        fetchBooks(forSubjects: categories)
        fetchAllBooks(forSubjects: categories)
    }
    
    private func fetchBooks(forSubjects subjects: [String]) {
        let session = URLSession.shared
        let baseURL = "https://openlibrary.org/subjects/"
        
        for subject in subjects {
            let urlString = "\(baseURL)\(subject).json?limit=10"
            guard let url = URL(string: urlString) else { continue }
            
            let task = session.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching books for subject: \(subject)")
                    return
                }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let works = jsonResult["works"] as? [[String: Any]] {
                        var fetchedBooks: [Book] = []
                        for work in works {
                            if let title = work["title"] as? String,
                               let coverEditionKey = work["cover_edition_key"] as? String,
                               let key = work["key"] as? String {
                                let book = Book(title: title, isbn: coverEditionKey, key: key)
                                fetchedBooks.append(book)
                            }
                        }
                        DispatchQueue.main.async {
                            self?.books = fetchedBooks.shuffled()
                            self?.collectionView.reloadData()
                            self?.fetchBooksCover()
                        }
                    }
                } catch {
                    print("Failed to decode JSON for subject: \(subject)")
                }
            }
            task.resume()
        }
    }
    
    private func fetchBooksCover() {
        for (index, book) in books.enumerated() {
            guard let isbn = book.isbn else {
                DispatchQueue.main.async {
                    self.books[index].image = self.defaultCoverImage
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
                continue
            }
            
            let coverUrlString = "https://covers.openlibrary.org/b/olid/\(isbn)-L.jpg"
            guard let coverUrl = URL(string: coverUrlString) else {
                DispatchQueue.main.async {
                    self.books[index].image = self.defaultCoverImage
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
                continue
            }
            
            let task = URLSession.shared.dataTask(with: coverUrl) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self?.books[index].image = self?.defaultCoverImage
                        self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                    return
                }
                
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if index < self?.books.count ?? 0 {
                            self?.books[index].image = image
                            self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.books[index].image = self?.defaultCoverImage
                        self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
            }
            task.resume()
        }
    }
    
    private func fetchAllBooks(forSubjects subjects: [String]) {
        let session = URLSession.shared
        let baseURL = "https://openlibrary.org/subjects/"
        
        for subject in subjects {
            let urlString = "\(baseURL)\(subject).json?limit=20"
            guard let url = URL(string: urlString) else { continue }
            
            let task = session.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching all books for subject: \(subject)")
                    return
                }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let works = jsonResult["works"] as? [[String: Any]] {
                        var fetchedAllBooks: [AllBook] = []
                        for work in works {
                            if let title = work["title"] as? String,
                               let coverEditionKey = work["cover_edition_key"] as? String,
                               let key = work["key"] as? String {
                                let allBook = AllBook(title: title, isbn: coverEditionKey, key: key)
                                fetchedAllBooks.append(allBook)
                            }
                        }
                        DispatchQueue.main.async {
                            self?.allBooks[subject] = fetchedAllBooks
                            self?.categoriesTableView.reloadData()
                            self?.fetchAllBooksCover(for: subject)
                        }
                    }
                } catch {
                    print("Failed to decode JSON for subject: \(subject)")
                }
            }
            task.resume()
        }
    }
    
    private func fetchAllBooksCover(for category: String) {
        guard let books = allBooks[category] else { return }
        
        for (index, allBook) in books.enumerated() {
            guard let isbn = allBook.isbn else {
                DispatchQueue.main.async {
                    self.allBooks[category]?[index].image = self.defaultCoverImage
                    self.categoriesTableView.reloadData()
                }
                continue
            }
            
            let coverUrlString = "https://covers.openlibrary.org/b/olid/\(isbn)-M.jpg"
            guard let coverUrl = URL(string: coverUrlString) else {
                DispatchQueue.main.async {
                    self.allBooks[category]?[index].image = self.defaultCoverImage
                    self.categoriesTableView.reloadData()
                }
                continue
            }
            
            let task = URLSession.shared.dataTask(with: coverUrl) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self?.allBooks[category]?[index].image = self?.defaultCoverImage
                        self?.categoriesTableView.reloadData()
                    }
                    return
                }
                
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.allBooks[category]?[index].image = image
                        self?.categoriesTableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.allBooks[category]?[index].image = self?.defaultCoverImage
                        self?.categoriesTableView.reloadData()
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Navigation
    
    func showCategoryDetail(for category: String) {
        let detailVC = CategoryDetailViewController(category: category)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelectBookAt index: Int) {
        guard let indexPath = categoriesTableView.indexPath(for: cell),
                      let selectedBook = allBooks[categories[indexPath.row]]?[index] else {
                    return
                }
                
                let detailsController = DetailsController()
                detailsController.bookKey = selectedBook.key
                navigationController?.pushViewController(detailsController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension HomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return books.count
        } else if collectionView == self.categoriesCollectionView {
            return categories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCollectionViewCell.reuseIdentifier, for: indexPath) as? BookCollectionViewCell else {
                fatalError("Unable to dequeue BookCollectionViewCell")
            }
            let book = books[indexPath.item]
            cell.configure(with: book)
            return cell
        } else if collectionView == self.categoriesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryButtonCell.reuseIdentifier, for: indexPath) as? CategoryButtonCell else {
                fatalError("Unable to dequeue CategoryButtonCell")
            }
            let category = categories[indexPath.item]
            cell.configure(with: category)
            cell.categoryTapHandler = { [weak self] selectedCategory in
                self?.showCategoryDetail(for: selectedCategory)
            }
            return cell
        }
        fatalError("Unexpected CollectionView")
    }
}

// MARK: - UICollectionViewDelegate

extension HomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.categoriesCollectionView {
            let category = categories[indexPath.item]
            showCategoryDetail(for: category)
        } else if collectionView == self.collectionView {
            let selectedBook = books[indexPath.item]
            let detailsController = DetailsController()
            detailsController.bookKey = selectedBook.key
            navigationController?.pushViewController(detailsController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension HomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as! CategoryTableViewCell
           let category = categories[indexPath.row]
           cell.configure(with: category, books: allBooks[category] ?? [])
           cell.delegate = self
           return cell
       }
}

// MARK: - UITableViewDelegate

extension HomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
}

// MARK: - BookCollectionViewCell

class BookCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "BookCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
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
        contentView.addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        imageView.image = book.image ?? UIImage(named: "default_cover_image")
    }
}

// MARK: - CategoryTableViewCell

class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"
    
    weak var delegate: CategoryTableViewCellDelegate?
    private var category: String?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 160)
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AllBookCollectionViewCell.self, forCellWithReuseIdentifier: AllBookCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private var books: [AllBook] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    func configure(with category: String, books: [AllBook]) {
        titleLabel.text = category.capitalized
        self.books = books
        self.category = category
        collectionView.reloadData()
    }
}

// MARK: - CategoryButtonCell

class CategoryButtonCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryButtonCell"
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.titleLabel?.textColor = .systemRed
        button.tintColor = .systemRed
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        return button
    }()
    
    var categoryTapHandler: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        button.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
    }
    
    func configure(with category: String) {
        button.setTitle(category.capitalized, for: .normal)
    }
    
    @objc private func categoryTapped() {
        categoryTapHandler?(button.title(for: .normal)?.lowercased() ?? "")
    }
}

// MARK: - AllBookCollectionViewCell

class AllBookCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "AllBookCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 10)
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
        contentView.addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with book: AllBook) {
        titleLabel.text = book.title
        imageView.image = book.image ?? UIImage(named: "default_cover_image")
    }
}

extension CategoryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllBookCollectionViewCell.reuseIdentifier, for: indexPath) as! AllBookCollectionViewCell
        let book = books[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoryTableViewCell(self, didSelectBookAt: indexPath.item)
    }
}
