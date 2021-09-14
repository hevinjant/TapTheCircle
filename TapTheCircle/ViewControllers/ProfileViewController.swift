//
//  ProfileViewController.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(didTapSignOut))
    }

    @objc private func didTapSignOut() {
        let sheet = UIAlertController(title: "Sign Out", message: "Do you want to sign out?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut(completion: { [weak self] success in
                DispatchQueue.main.async {
                    // clear user cache
                    UserDefaults.standard.set(nil, forKey: "email")
                    UserDefaults.standard.set(nil, forKey: "name")
                    
                    let signInVC = SignInViewController()
                    signInVC.navigationItem.largeTitleDisplayMode = .always
                    let navVC = UINavigationController(rootViewController: signInVC)
                    navVC.navigationBar.prefersLargeTitles = true
                    navVC.modalPresentationStyle = .fullScreen
                    self?.present(navVC, animated: true)
                }
            })
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(sheet, animated: true)
    }
}
