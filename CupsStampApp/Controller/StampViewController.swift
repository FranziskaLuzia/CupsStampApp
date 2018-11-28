//
//  StampViewController.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/13/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//


import UIKit
import Firebase
import FirebaseFirestore

class StampViewController: UIViewController {
    static let segueIdentifier = "showMain"
    static let starPassword = "Tester12"

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet weak var earnedDrinksButton: UIButton!

    private let currentUserId = Firebase.Auth.auth().currentUser?.uid ?? ""
    private lazy var documentReference: DocumentReference = {
        return Firestore.firestore().collection("users").document(currentUserId)
    }()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }()

    private var greeting: String {
        let hours = Int(self.dateFormatter.string(from: Date()))!
        return hours < 12 ? "Good morning" : "Good afternoon"
    }

    private var user: User? {
        didSet {
            guard let user = user else { return }
            greetingLabel.text = greeting + " \(user.name).\nYour punch card looks good!"
            updateStars()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        earnedDrinksButton.layer.cornerRadius = 15
        earnedDrinksButton.isHidden = true
    }

    private func fetchUser() {
        documentReference.getDocument { [weak self] doc, error in
            guard let strongSelf = self else { return }
            guard
                let doc = doc?.data(),
                let name = doc[User.Keys.name.rawValue] as? String,
                let stamps = doc[User.Keys.stamps.rawValue] as? Int
            else {
                return
            }

            let dict: [String: Any] = [User.Keys.id.rawValue: strongSelf.currentUserId,
                        User.Keys.name.rawValue: name,
                        User.Keys.stamps.rawValue: stamps]
            if let user = User(dict: dict) {
                strongSelf.user = user
            }
        }
    }

    private func signout() {
        do {
            try Firebase.Auth.auth().signOut()
            self.dismiss(animated: false, completion: nil)
        } catch {
            UIAlertController.show(title: "Sorry!", message: "Something went wrong.", on: self)
        }
    }

    private func showInputPopup(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: nil, message: "Show this to someone from Cups", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Password"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            let field = alert.textFields!.first!
            completion(field.text ?? "")
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Actions

extension StampViewController {
    @IBAction func didTapCard(_ sender: Any) {
        showInputPopup() { [weak self] input in
            guard let strongSelf = self else { return }
            if input == StampViewController.starPassword {
                strongSelf.user?.addStamp()
                strongSelf.updateStars()
            } else if input.count > 0 {
                UIAlertController.show(title: "Sorry", message: "The password was wrong.", on: strongSelf)
            }
        }
    }

    @IBAction func didTapEarnedDrinksButton(_ sender: Any) {
        // show alert with to redeem drinks
        UIAlertController.show(title: "", message: "Do you want to redeem a free drink?", on: self, shouldAddCancelButton: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.user?.redeem()
            strongSelf.updateStars()
        }
    }

    @IBAction func didTapLogout(_ sender: Any) {
        signout()
    }
}

// MARK: Stamp Management

extension StampViewController {
    private func updateStars() {
        guard let stamps = user?.stamps else {
            return
        }

        let numberOfStars = stamps % 10
        let numberOfRewards = Int(stamps / 10)
        earnedDrinksButton.isHidden = numberOfRewards == 0
        earnedDrinksButton.setTitle("\(numberOfRewards)", for: .normal)

        for (index, star) in stars.enumerated() {
            if index <= numberOfStars - 1 {
                star.tintColor = .white
                star.isHidden = false
            } else {
                star.isHidden = true
            }
        }
    }
}
