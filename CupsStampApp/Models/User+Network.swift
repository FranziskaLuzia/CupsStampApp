//
//  User+Network.swift
//  CupsStampApp
//
//  Created by Florian Thompson on 11/28/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

extension User {
    private static var currentUserId: String {
        return Firebase.Auth.auth().currentUser?.uid ?? ""
    }

    private static var documentReference: DocumentReference = {
        return Firestore.firestore().collection("users").document(currentUserId)
    }()

    static func sync(completion: @escaping (User?) -> Void) {
        documentReference.getDocument { doc, error in
            guard
                let doc = doc?.data(),
                let name = doc[User.Keys.name.rawValue] as? String,
                let stamps = doc[User.Keys.stamps.rawValue] as? Int
            else { return completion(nil) }
Test
            let dict: [String: Any] = [User.Keys.id.rawValue: currentUserId,
                                       User.Keys.name.rawValue: name,
                                       User.Keys.stamps.rawValue: stamps]
            completion(User(dict: dict))
        }
    }

    func persistToFirebase() {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.setData([Keys.name.rawValue: name])
    }

    func updateStampsOnBackend() {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.updateData([User.Keys.stamps.rawValue: stamps])
    }
}
