//
//  SignUpViewController.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 10/23/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit
import Firebase
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

    private func updateStampsOnBackend() {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.updateData([User.Keys.stamps.rawValue: stamps])
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return (lhs.id + lhs.name + "\(lhs.stamps)") == (rhs.id + rhs.name + "\(rhs.stamps)")
    }
}

// Network
extension User {
    func persistToFirebase() {
        let doc = Firestore.firestore().collection("users").document(id)
        doc.setData([Keys.name.rawValue: name])
    }
}

class SignUpViewController: UIViewController {
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    private var name: String? {
        didSet { changeSignupButtonStateIfNeeded() }
    }
    private var email: String? {
        didSet { changeSignupButtonStateIfNeeded() }
    }
    private var password: String? {
        didSet { changeSignupButtonStateIfNeeded() }
    }
    
    private let nameTag = 1
    private let emailTag = 2
    private let passwordTag = 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.isEnabled = false
        nameTextfield.tag = nameTag
        emailTextfield.tag = emailTag
        passwordTextfield.tag = passwordTag
        signupButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        nameTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField.tag {
        case nameTag:
            name = textField.text
        case emailTag:
            email = textField.text
        case passwordTag:
            password = textField.text
        default: break
        }
    }
    
    private func changeSignupButtonStateIfNeeded() {
        guard
            let name = name,
            let email = email,
            let password = password,
            name.trimmingCharacters(in: .whitespaces).count > 0,
            email.trimmingCharacters(in: .whitespaces).count > 0,
            password.trimmingCharacters(in: .whitespaces).count > 0
        else {
            signupButton.isEnabled = false
            return
        }
        
        signupButton.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func didTapSignupButton(_ sender: Any) {
        guard let name = name, let email = email, let password = password else {
            return
        }

        Firebase.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            if let error = error {
                UIAlertController.show(title: "We're Sorry!", message: error.localizedDescription, on: strongSelf)
            }

            // save user
            if let firUser = result?.user {
                let user = User(id: firUser.uid, name: name)
                user.persistToFirebase()
                strongSelf.presentMain()
            }
        }

        print("signing up with: email: \(email), password: \(password), name: \(name)")
    }
}

// Mark: Navigation

extension SignUpViewController {
    private func resetTextFields() {
        emailTextfield.text = ""
        passwordTextfield.text = ""
        nameTextfield.text = ""
        email = ""
        password = ""
        name = ""
    }

    private func presentMain() {
        resetTextFields()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Main")
        present(vc, animated: false, completion: nil)
    }
}
