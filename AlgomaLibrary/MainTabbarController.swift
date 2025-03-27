//
//  MainTabbarController.swift
//  AlgomaLibrary
//
//  Created by Lab8student on 2024-07-16.
//

import UIKit

class MainTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize view controllers
        let homeVC = UINavigationController(rootViewController: HomeController())
        let profileVC = UINavigationController(rootViewController: ProfileController())
        let booksVC = UINavigationController(rootViewController: BooksController())
        let bookMarkVC = UINavigationController(rootViewController: BookmarkController())
        let forumVC = UINavigationController(rootViewController: ForumController())
        
        // Set tab bar items
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house")?.withTintColor(.red, renderingMode: .alwaysOriginal), tag: 0)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person")?.withTintColor(.red, renderingMode: .alwaysOriginal), tag: 1)
        booksVC.tabBarItem = UITabBarItem(title: "Books", image: UIImage(systemName: "book")?.withTintColor(.red, renderingMode: .alwaysOriginal), tag: 2)
        bookMarkVC.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark")?.withTintColor(.red, renderingMode: .alwaysOriginal), tag: 3)
        forumVC.tabBarItem = UITabBarItem(title: "Forum", image: UIImage(systemName: "bubble.left.and.bubble.right")?.withTintColor(.red, renderingMode: .alwaysOriginal), tag: 4)
        
        // Set the view controllers of the tab bar
        self.viewControllers = [homeVC, profileVC, booksVC, bookMarkVC, forumVC]
        
        // Customize tab bar appearance
        tabBar.barTintColor = .white  // Set the background color to white
        // Customize the tab bar item appearance
        let appearance = UITabBarItem.appearance()
        appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .selected)
    }
}
