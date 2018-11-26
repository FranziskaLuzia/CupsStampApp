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
    }

    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    convenience init?(dict: [String: Any]) {
        guard
            let id = dict[User.Keys.name.rawValue] as? String,
            let name = dict[User.Keys.id.rawValue] as? String
        else {
            return nil
        }
        
        self.init(id: id, name: name)
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
    
    @IBAction func didTapSignupButton(_ sender: Any) {
        guard let name = name, let email = email, let password = password else {
            return
        }
        
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            if let _ = error {
                UIAlertController.show(title: "We're Sorry!", message: "Something went wrong.", on: strongSelf)
            }
            
            // get user
            if let firUser = result?.user {
                let user = User(id: firUser.uid, name: name)
                user.persistToFirebase()
            }
        }

        print("signing up with: email: \(email), password: \(password), name: \(name)")
    }
}
