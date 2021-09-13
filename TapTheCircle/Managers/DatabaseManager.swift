//
//  DatabaseManager.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/12/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    
    public func safeEmail(email: String) -> String {
        return email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
    }
    
    public func insertUser(user: User, completion: @escaping (Bool) -> Void) {
        let userEmail = safeEmail(email: user.email)
        let data = [
            "email": userEmail,
            "name": user.name
        ]
        
        database.collection("users").document(userEmail).setData(data, completion: { error in
            completion(error == nil)
        })
    }
    
    public func getUser(email: String, completion: @escaping (User?) -> Void) {
        let userPath = safeEmail(email: email)
        
        database.collection("users").document(userPath).getDocument(completion: { snapshot, error in
            guard let data = snapshot?.data(),
            let name = data["name"] as? String,
            let highestScore = data["highest_score"] as? Int,
                error == nil else {
                    return
            }
            
            let user = User(name: name, email: email, highestScore: highestScore)
            completion(user)
        })
    }
    
    public func insertUserLog(for email: String, userLog: UserLog, completion: @escaping (Bool) -> Void) {
        
    }
    
    public func getUserLog(for email: String, completion: @escaping (UserLog?) -> Void) {
        
    }
    
    public func getAllUserLogs(completion: @escaping ([UserLog]) -> Void) {
        
    }
}
