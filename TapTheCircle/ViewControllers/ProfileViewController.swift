//
//  ProfileViewController.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    private var user: User?
    private var currentUserLogs: [UserLog] = []
    let currentEmail: String
    var highestScore = 0
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.tableFooterView = UIView()
        return table
    }()
    
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(didTapSignOut))
        
        // add subviews
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupTableHeader()
        fetchUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // assign frames
        tableView.frame = view.bounds
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
    
    private func fetchUser() {
        DatabaseManager.shared.getUser(email: currentEmail, completion: { [weak self] user in
            guard let user = user else {
                print("Failed to fetch user")
                return
            }
            self?.user = user
            
            self?.getCurrentUserLogs(email: user.email)
            
            DispatchQueue.main.async {
                self?.setupTableHeader(profileImageRef: user.profileImageRef)
                self?.tableView.reloadData()
            }
        })
    }
    
    private func getCurrentUserLogs(email: String) {
        DatabaseManager.shared.getUserLog(for: email, completion: { [weak self] userLogs in
            self?.currentUserLogs = userLogs
            
            if let highestScore = self?.getCurrentUserHighestScore() {
                self?.highestScore = highestScore
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
    }
    
    private func getCurrentUserHighestScore() -> Int {
        var highestScore = 0
         for userLog in currentUserLogs {
             if userLog.score > highestScore {
                 highestScore = userLog.score
             }
         }
         return highestScore
    }
    
    private func setupTableHeader(profileImageRef: String? = nil) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/2))
        headerView.backgroundColor = .systemBackground
        headerView.clipsToBounds = true
        headerView.isUserInteractionEnabled = true
        tableView.tableHeaderView = headerView
        
        let profileImage = UIImageView(image: UIImage(systemName: "person.circle"))
        profileImage.tintColor = .white
        profileImage.contentMode = .scaleAspectFit
        profileImage.frame = CGRect(x: (view.width-(view.width/4))/2, y: (headerView.height-(view.width/4))/2, width: view.width/4, height: view.width/4)
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.width/2
        profileImage.isUserInteractionEnabled = true
        headerView.addSubview(profileImage)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImage.addGestureRecognizer(tap)
        
        if let ref = profileImageRef {
            // fetch image
            StorageManager.shared.downloadUrlForProfileImage(path: ref, completion: { url in
                guard let url = url else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url, completionHandler: { imageData, _, _ in
                    guard let imageData = imageData else {
                        return
                    }
                    DispatchQueue.main.async {
                        profileImage.image = UIImage(data: imageData)
                    }
                })
                task.resume()
            })
        }
    }
    
    @objc private func didTapProfileImage() {
        print("Tapped")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var name: String? = nil
        if let user = self.user {
            name = user.name
        }
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Name: \(name ?? "User not found")"
            break
        case 1:
            cell.textLabel?.text = "Highest Score: \(highestScore)"
            break
        default:
            break
        }
        return cell
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        StorageManager.shared.uploadUserProfileImage(email: self.currentEmail, image: image, completion: { [weak self] success in
            guard let strongSelf = self else {
                return
            }
            if success {
                DatabaseManager.shared.updateUserProfileImageRef(email: strongSelf.currentEmail, completion: { success in
                    if success {
                        DispatchQueue.main.async {
                            strongSelf.fetchUser()
                        }
                    }
                })
            }
        })
    }
}
