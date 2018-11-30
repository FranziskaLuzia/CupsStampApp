//
//  User+Local.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/28/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import Foundation

extension User {
    static func fetchLocally() -> User? {
        do {
            guard let data = UserDefaults.standard.object(forKey: User.documentIdentifier) as? Data else { return nil }
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            print("Unarchiving failed")
            return nil
        }
    }

    static func clearDefaults() {
//        UserDefaults.standard.removeObject(forKey: User.documentIdentifier)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
    }
}
