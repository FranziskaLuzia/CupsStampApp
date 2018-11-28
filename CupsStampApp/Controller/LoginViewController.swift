//
//  LoginViewController.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 10/14/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    private var email: String? {
        didSet { changeSigInButtonStateIfNeeded() }
    }
    private var password: String? {
        didSet { changeSigInButtonStateIfNeeded() }
    }
    private let emailTag = 1
    private let passwordTag = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if already signed in
        if let _ = Firebase.Auth.auth().currentUser {
            presentMain()
            return
        }

        signInButton.isEnabled = false
        signInButton.setTitleColor(UIColor.lightGray, for: .disabled)
        emailTextfield.tag = emailTag
        passwordTextfield.tag = passwordTag
        emailTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField.tag {
        case emailTag:
            email = textField.text
        case passwordTag:
            password = textField.text
        default: break
        }
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        signIn()
    }
    
    private func signIn() {
        guard let email = email, let password = password else {
            return
        }
    
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                UIAlertController.show(title: "We're Sorry!", message: "Something went wrong. Please double check your email and password.", on: strongSelf)
            }

            if let _ = result?.user {
                strongSelf.presentMain()
            }
        }
    }
    
    private func changeSigInButtonStateIfNeeded() {
        guard
            let email = email,
            let password = password,
            email.trimmingCharacters(in: .whitespaces).count > 0,
            password.trimmingCharacters(in: .whitespaces).count > 0
        else {
            signInButton.isEnabled = false
            return
        }

        signInButton.isEnabled = true
    }
}

// Mark: Navigation

extension LoginViewController {
    private func presentMain() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Main")
        present(vc, animated: false, completion: nil)
    }
}

extension UIAlertController {
    static func show(title: String, message: String, on viewController: UIViewController, shouldAddCancelButton: Bool = false, okCallback: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: okCallback))
        if shouldAddCancelButton {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        viewController.present(alertController, animated: true, completion: nil)
    }
}
