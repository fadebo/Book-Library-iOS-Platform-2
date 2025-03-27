//
//  CategoryDetailViewController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-16.
//

import UIKit

class CategoryDetailViewController: UIViewController {
    private let category: String
    private var books: [AllBook] = []
    private var filteredBooks: [AllBook] = []

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search books"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.width - 40, height: 120)
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookDetailCell.self, forCellWithReuseIdentifier: BookDetailCell.reuseIdentifier)
        return collectionView
    }()

    init(category: String) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        searchBar.delegate = self
        fetchBooks()
    }

    private func setupUI() {
        title = category.capitalized
        view.backgroundColor = .systemBackground

        view.addSubview(searchBar)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func fetchBooks() {
        print("Fetching books for category: \(category)")
        let formattedCategory = category.lowercased().replacingOccurrences(of: " ", with: "_")
        let urlString = "https://openlibrary.org/subjects/\(formattedCategory).json?limit=200"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching books: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let works = jsonResult["works"] as? [[String: Any]] {
                    self?.books = works.compactMap { work -> AllBook? in
                        guard let title = work["title"] as? String,
                              let key = work["key"] as? String,
                              let coverEditionKey = work["cover_edition_key"] as? String else {
                            return nil
                        }
                        return AllBook(title: title, isbn: coverEditionKey, key: key)
                    }
                    self?.books = (self?.books.shuffled())!
                    self?.filteredBooks = self?.books ?? []
                    DispatchQueue.main.async {
                        self?.books = (self?.books.shuffled())!
                        self?.collectionView.reloadData()
                        self?.fetchBookCovers()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func fetchBookCovers() {
        for (index, book) in books.enumerated() {
            guard let isbn = book.isbn else { continue }
            let coverUrlString = "https://covers.openlibrary.org/b/olid/\(isbn)-M.jpg"
            guard let coverUrl = URL(string: coverUrlString) else { continue }
            
            URLSession.shared.dataTask(with: coverUrl) { [weak self] data, response, error in
                guard let self = self, let data = data, error == nil else { return }
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // Update books array
                        if index < self.books.count {
                            self.books[index].image = image
                        }
                        
                        // Update filteredBooks array
                        if let filteredIndex = self.filteredBooks.firstIndex(where: { $0.isbn == isbn }) {
                            self.filteredBooks[filteredIndex].image = image
                        }
                        
                        // Reload the specific item in the collection view
                        if let visibleIndex = self.filteredBooks.firstIndex(where: { $0.isbn == isbn }) {
                            self.collectionView.reloadItems(at: [IndexPath(item: visibleIndex, section: 0)])
                        }
                    }
                }
            }.resume()
        }
    }
}

extension CategoryDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of filtered books: \(filteredBooks.count)")
        return filteredBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookDetailCell.reuseIdentifier, for: indexPath) as! BookDetailCell
        cell.configure(with: filteredBooks[indexPath.item])
        return cell
    }
    //Open book detaiils
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            let selectedBook = filteredBooks[indexPath.item]
            let detailsController = DetailsController()
            detailsController.bookKey = selectedBook.key
            navigationController?.pushViewController(detailsController, animated: true)
        }
    }
}

extension CategoryDetailViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredBooks = books
        } else {
            filteredBooks = books.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
    }
}
// TODO: - Add a bookmark button to each bookdetail cell

class BookDetailCell: UICollectionViewCell {
    static let reuseIdentifier = "BookDetailCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
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
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2/3),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with book: AllBook) {
        titleLabel.text = book.title
        imageView.image = book.image ?? UIImage(named: "default_cover_image")
    }
}
