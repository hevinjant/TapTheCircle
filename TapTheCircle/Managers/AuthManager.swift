//
//  AuthManager.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/12/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    
    /// Check if a user is signed in.
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    /// Create a new Firebase user with email.
    public func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
            !password.trimmingCharacters(in: .whitespaces).isEmpty,
            password.count >= 6 else {
                completion(false)
                return
        }
        
        auth.createUser(withEmail: email, password: password, completion: { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Sign in user.
    public func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
            !password.trimmingCharacters(in: .whitespaces).isEmpty,
            password.count >= 6 else {
                completion(false)
                return
        }
        
        auth.signIn(withEmail: email, password: password, completion: { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Sign out user.
    public func signOut(completion: (Bool) -> Void) {
        do {
            try auth.signOut()
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
}
