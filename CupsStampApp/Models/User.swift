//
//  User.swift
//  CupsStampApp
//
//  Created by Florian Thompson on 11/28/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import Foundation
import FirebaseFirestore

class User: NSObject {
    enum Keys: String, CodingKey {
        case name
        case id
        case stamps
    }

    static let documentIdentifier = "user"

    let id: String
    let name: String
    var stamps: Int {
        didSet {
            persistLocally()
        }
    }

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
        super.init()

        persistLocally()
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

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        stamps = try container.decode(Int.self, forKey: .stamps)
    }

    func addStamp(_ numberOfStamps: Int) {
        stamps += numberOfStamps
        updateStampsOnBackend()
    }

    func redeem() {
        guard stamps >= 10 else { return }
        stamps -= 10
        updateStampsOnBackend()
    }

    private func persistLocally() {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(self)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: User.documentIdentifier)
            defaults.synchronize()
        } catch {
            print("archiving failed")
        }
    }
}

extension User: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(stamps, forKey: .stamps )
    }
}
