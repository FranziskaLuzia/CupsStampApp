//
//  User+Network.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/28/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

extension User {
    static func sync(completion: @escaping (User?) -> Void) {
        let currentUserId = Firebase.Auth.auth().currentUser?.uid ?? ""
        let reference = Firestore.firestore().collection("users").document(currentUserId)
        reference.getDocument { doc, error in
            guard
                let doc = doc?.data(),
                let name = doc[User.Keys.name.rawValue] as? String
            else { return completion(nil) }
            let dict: [String: Any] = [User.Keys.id.rawValue: currentUserId,
                                       User.Keys.name.rawValue: name,
                                       User.Keys.stamps.rawValue: (doc[User.Keys.stamps.rawValue] as? Int) ?? 0]
            completion(User(dict: dict))
        }
    }

    func persistToFirebase(completion: @escaping (Error?) -> Void) {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.setData([Keys.name.rawValue: name]) { error in
            completion(error)
        }
    }

    func updateStampsOnBackend() {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.updateData([User.Keys.stamps.rawValue: stamps])
    }
}
