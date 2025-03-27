//
//  BooksController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-16.
//

import UIKit

class BooksController: UIViewController {
    // MARK: - Variables
    private var allBooks: [Book] = []
    private var filteredBooks: [Book] = []
    private let categories = ["art", "fiction", "biology", "chemistry", "physics", "programming", "maths", "finance", "archaeology", "psychology", "political_science"]
    private let defaultCoverImage = UIImage(named: "default_cover")

    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search books..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.width / 3 - 20, height: 200)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: BookCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Books"
        self.view.backgroundColor = .systemBackground
        setupUI()
        fetchAllBooks()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Data Fetching
    private func fetchAllBooks() {
        let session = URLSession.shared
        let baseURL = "https://openlibrary.org/subjects/"
        var fetchedBooks: [Book] = []

        let dispatchGroup = DispatchGroup()

        for subject in categories {
            dispatchGroup.enter()
            let urlString = "\(baseURL)\(subject).json?limit=200"
            guard let url = URL(string: urlString) else {
                dispatchGroup.leave()
                continue
            }

            let task = session.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                guard let data = data, error == nil else {
                    print("Error fetching books for subject: \(subject)")
                    return
                }

                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let works = jsonResult["works"] as? [[String: Any]] {
                        for work in works {
                            if let title = work["title"] as? String,
                               let coverEditionKey = work["cover_edition_key"] as? String,
                               let key = work["key"] as? String {
                                let book = Book(title: title, isbn: coverEditionKey, key: key)
                                fetchedBooks.append(book)
                            }
                        }
                        
                    }
                } catch {
                    print("Failed to decode JSON for subject: \(subject)")
                }
            }
            task.resume()
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.allBooks = fetchedBooks.shuffled()
            self?.filteredBooks = self?.allBooks ?? []
            self?.collectionView.reloadData()
            self?.fetchBookCovers()
        }
    }

    private func fetchBookCovers() {
        for (index, book) in allBooks.enumerated() {
            guard let isbn = book.isbn else {
                self.allBooks[index].image = self.defaultCoverImage
                continue
            }

            let coverUrlString = "https://covers.openlibrary.org/b/olid/\(isbn)-M.jpg"
            guard let coverUrl = URL(string: coverUrlString) else {
                self.allBooks[index].image = self.defaultCoverImage
                continue
            }

            let task = URLSession.shared.dataTask(with: coverUrl) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self?.allBooks[index].image = self?.defaultCoverImage
                        self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                    return
                }

                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.allBooks[index].image = image
                        self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.allBooks[index].image = self?.defaultCoverImage
                        self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
            }
            task.resume()
        }
    }

    // MARK: - Search Functionality
    private func filterBooks(with searchText: String) {
        if searchText.isEmpty {
            filteredBooks = allBooks
        } else {
            filteredBooks = allBooks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension BooksController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCollectionViewCell.reuseIdentifier, for: indexPath) as? BookCollectionViewCell else {
            fatalError("Unable to dequeue BookCollectionViewCell")
        }
        let book = filteredBooks[indexPath.item]
        cell.configure(with: book)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension BooksController: UICollectionViewDelegate {
    // Implement any delegate methods if needed
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            let selectedBook = filteredBooks[indexPath.item]
            let detailsController = DetailsController()
            detailsController.bookKey = selectedBook.key
            navigationController?.pushViewController(detailsController, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate
extension BooksController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterBooks(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
