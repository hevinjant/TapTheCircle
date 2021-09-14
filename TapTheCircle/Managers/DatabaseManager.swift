//
//  DatabaseManager.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/12/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit

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
                    print("Error getting document.")
                    return
            }
            
            let user = User(name: name, email: email, highestScore: highestScore)
            completion(user)
        })
    }
    
    public func insertUserLog(userLog: UserLog, completion: @escaping (Bool) -> Void) {
        let userEmail = safeEmail(email: userLog.email)
        
        let data: [String: Any] = [
            "id": userLog.id,
            "name": userLog.name,
            "email": userLog.email,
            "score": userLog.score,
            "match_time": userLog.matchTime,
            "time_stamp": userLog.timeStamp
        ]
        
        database.collection("users").document(userEmail).collection("user_logs").document(userLog.id).setData(data, completion: { error in
            if let error = error {
                print("Failed to insert user log: \(error)")
                completion(false)
            }
            completion(true)
        })
    }
    
    public func getUserLog(for email: String, completion: @escaping ([UserLog]) -> Void) {
        let userEmail = safeEmail(email: email)
        
        database.collection("users").document(userEmail).collection("user_logs").getDocuments(completion: { snapshot, error in
            guard let documents = snapshot?.documents.compactMap({ $0.data() }), error == nil else {
                print("Failed to get user logs for user: \(email)")
                return
            }
            
            let userLogs: [UserLog] = documents.compactMap({ dictionary in
                guard let id = dictionary["id"] as? String,
                let name = dictionary["name"] as? String,
                let email = dictionary["email"] as? String,
                let score = dictionary["score"] as? Int,
                let matchTime = dictionary["match_time"] as? Int,
                    let timeStamp = dictionary["time_stamp"] as? TimeInterval else {
                        return nil
                }
                
                let userLog = UserLog(id: id, name: name, email: email, score: score, matchTime: matchTime, timeStamp:  timeStamp)
                
                return userLog
            })
            completion(userLogs)
        })
    }
    
    public func getAllUserLogs(completion: @escaping ([UserLog]) -> Void) {
        database.collection("users").getDocuments(completion: { [weak self] snapshot, error in
            guard let documents = snapshot?.documents.compactMap({ $0.data() }), error == nil else {
                print("Failed to get all user logs.")
                return
            }
            let allUserEmails: [String] = documents.compactMap({ return $0["email"] as? String })
            
            guard !allUserEmails.isEmpty else {
                completion([])
                return
            }
            
            let group = DispatchGroup()
            var result: [UserLog] = []
            for email in allUserEmails {
                group.enter()
                self?.getUserLog(for: email, completion: { userLogs in
                    defer {
                        group.leave()
                    }
                    result.append(contentsOf: userLogs)
                })
            }
            group.notify(queue: .global(), execute: {
                completion(result)
            })
            
        })
    }
}

