//
//  StampViewController.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/13/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//


import UIKit
import Firebase

class StampViewController: UIViewController {
    static let segueIdentifier = "showMain"

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet var stars: [UIImageView]!

    private let currentUserId = Firebase.Auth.auth().currentUser?.uid ?? ""
    private lazy var documentReference: DocumentReference = {
        return Firestore.firestore().collection("users").document(currentUserId)
    }()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }()

    // TODO: load label smartly
    private var greeting: String {
        let hours = Int(self.dateFormatter.string(from: Date()))!
        return hours < 12 ? "Good morning" : "Good afternoon"
    }

    private var user: User? {
        didSet {
            guard let user = user else { return }
            greetingLabel.text = greeting + " \(user.name).\nYour punch card looks good!"
            let string = self.dateFormatter.string(from: Date())
            print(string)
            // set stamps
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // fetch user
        fetchUser()
        for star in stars {
            star.tintColor = .white
            star.isHidden = false
        }
    }

    private func fetchUser() {
        documentReference.getDocument { [weak self] doc, error in
            guard let strongSelf = self else { return }
            guard let doc = doc?.data(), let name = doc[User.Keys.name.rawValue] as? String else { return }
            let dict = [User.Keys.id.rawValue: strongSelf.currentUserId, User.Keys.name.rawValue: name]
            if let user = User(dict: dict) {
                strongSelf.user = user
            }
        }
    }

    @IBAction func didTapLogout(_ sender: Any) {
        signout()
    }

    private func signout() {
        do {
            try Firebase.Auth.auth().signOut()
            self.dismiss(animated: false, completion: nil)
        } catch {
            UIAlertController.show(title: "Sorry!", message: "Something went wrong.", on: self)
        }
    }

    @IBAction func didTapCard(_ sender: Any) {

    }
}
