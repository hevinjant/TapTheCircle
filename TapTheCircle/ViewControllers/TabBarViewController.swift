//
//  TabBarViewController.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

       setupControllers()
    }

    private func setupControllers() {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        
        let homeVC = HomeViewController()
        homeVC.navigationItem.largeTitleDisplayMode = .always
        
        let profileVC = ProfileViewController(currentEmail: currentUserEmail)
        profileVC.navigationItem.largeTitleDisplayMode = .always
        
        let navHomeVC = UINavigationController(rootViewController: homeVC)
        navHomeVC.navigationBar.prefersLargeTitles = true
        navHomeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "star.circle"), tag: 1)
        
        let navProfileVC = UINavigationController(rootViewController: profileVC)
        navProfileVC.navigationBar.prefersLargeTitles = true
        navProfileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 2)
        
        setViewControllers([navHomeVC, navProfileVC], animated: true)
    }
}
