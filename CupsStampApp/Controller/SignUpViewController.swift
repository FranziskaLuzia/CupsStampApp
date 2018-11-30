//
//  SignUpViewController.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 10/23/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signupButton: UIButton!

    private let spinner = Spinner()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))

        // Spinner
        view.addSubview(spinner)
        spinner.center = view.center
    }

    @objc func didTapView(_ ges: UITapGestureRecognizer) {
        view.endEditing(true)
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

        view.endEditing(true)
        spinner.show()

        User.signUp(with: email, password: password, name: name) { [weak self] success, error in
            guard let strongSelf = self else { return }
            strongSelf.spinner.hide()
            if let error = error {
                UIAlertController.show(title: "We're Sorry!", message: error.localizedDescription, on: strongSelf)
            }
            if success {
                strongSelf.presentMain()
            }
        }
    }
}

// MARK: Keyboard Listener

extension SignUpViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            guard view.frame.origin.y != 0 else { return }
            view.frame.origin.y = 0
        }
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
