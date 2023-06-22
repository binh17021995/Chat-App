//
//  DatabaseManager.swift
//  Chat App
//
//  Created by Duy Bình on 17/05/2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database(url:"https://chat-app-7e54d-default-rtdb.asia-southeast1.firebasedatabase.app" ).reference()
    static func safeEmail(emailAddress : String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

    
   
}

extension DatabaseManager {
    
    public func userExists(with email : String, completion : @escaping ((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
            "imageUser": user.profilePictureFileName
        ], withCompletionBlock: { [weak self] error, _ in

            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                print("failed ot write to database")
                completion(false)
                return
            }

            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail,
                        "imageUser": user.profilePictureFileName
                    ]
                    usersCollection.append(newElement)

                    strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
                else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail,
                            "imageUser": user.profilePictureFileName
                        ]
                    ]

                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
            })
        })
    }
    public func getAllUser(completion: @escaping (Result <[[String : String]], Error>) -> Void){

        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String : String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
}



struct ChatAppUser {
    let firstName : String
    let lastName : String
    let emailAddress : String
    
    var safeEmail : String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String {
        //afraz9-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}



