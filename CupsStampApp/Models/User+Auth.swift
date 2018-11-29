//
//  User+Auth.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/28/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import Foundation
import Firebase

extension User {
    static var isSignedIn: Bool {
        return Firebase.Auth.auth().currentUser != nil
    }
    static func signIn(with email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                return completion(false, error)
            }
            completion(true, nil)
        }
    }

    static func signUp(with email: String, password: String, name: String, completion: @escaping (Bool, Error?) -> Void) {
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                return completion(false, error)
            }

            // save user
            if let firUser = result?.user {
                let user = User(id: firUser.uid, name: name)
                user.persistToFirebase()
                completion(true, nil)
            }
        }
    }

    static func signOut() throws {
        try Firebase.Auth.auth().signOut()
    }
}
