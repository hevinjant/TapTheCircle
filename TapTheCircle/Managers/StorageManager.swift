//
//  StorageManager.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/18/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let container = Storage.storage()
    
    /// Upload user image to database.
    public func uploadUserProfileImage(email: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        let path = DatabaseManager().safeEmail(email: email)
        
        guard let pngData = image?.pngData() else {
            return
        }
        
        container.reference(withPath: "profile_pictures/\(path)/photo.png").putData(pngData, metadata: nil, completion: { metadata, error in
            guard metadata != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Download url for the user's image by given image reference.
    public func downloadUrlForProfileImage(path: String, completion: @escaping (URL?) -> Void) {
        container.reference(withPath: path).downloadURL(completion: { url, _ in
            completion(url)
        })
    }
}
