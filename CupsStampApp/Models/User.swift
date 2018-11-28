//
//  User.swift
//  CupsStampApp
//
//  Created by Florian Thompson on 11/28/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import Foundation
import FirebaseFirestore

class User {
    enum Keys: String {
        case name
        case id
        case stamps
    }

    let id: String
    let name: String
    private(set) var stamps: Int

    var numberOfStars: Int {
        return stamps % 10
    }

    var numberOfDrinksToRedeem: Int {
        return stamps / 10
    }

    init(id: String, name: String, stamps: Int = 0) {
        self.id = id
        self.name = name
        self.stamps = stamps
    }

    convenience init?(dict: [String: Any]) {
        guard
            let id = dict[User.Keys.id.rawValue] as? String,
            let name = dict[User.Keys.name.rawValue] as? String,
            let stamps = dict[User.Keys.stamps.rawValue] as? Int
            else {
                return nil
        }

        self.init(id: id, name: name, stamps: stamps)
    }

    func addStamp() {
        stamps += 1
        updateStampsOnBackend()
    }

    func redeem() {
        guard stamps >= 10 else { return }
        stamps -= 10
        updateStampsOnBackend()
    }
}

// MARK: Network

extension User {
    func persistToFirebase() {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.setData([Keys.name.rawValue: name])
    }

    private func updateStampsOnBackend() {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.updateData([User.Keys.stamps.rawValue: stamps])
    }
}
