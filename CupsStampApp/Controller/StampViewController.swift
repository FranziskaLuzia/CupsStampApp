//
//  StampViewController.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/13/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//


import UIKit

class StampViewController: UIViewController {
    static let starPassword = "Tester12"

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet weak var earnedDrinksButton: UIButton!

    private lazy var pickerContainerView: UIViewController = {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        return vc
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
    private var punchCardStatus: String {
        guard let user = user else { return "" }
        return user.numberOfStars >= 7 ? "Your punch card looks good!" : "Let's get some more coffee!"
    }
    private var user: User? = User.fetchLocally() {
        didSet {
            refresh()
        }
    }
    private var numberOfStampsToAdd = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        earnedDrinksButton.isHidden = true
        earnedDrinksButton.layer.cornerRadius = 15
        User.sync() { [weak self] in
            self?.user = $0
            self?.refresh()
        }
    }

    private func signout() {
        do {
            try User.signOut()
            self.dismiss(animated: false, completion: nil)
        } catch {
            UIAlertController.show(title: "Sorry!", message: "Something went wrong.", on: self)
        }
    }

    private func showInputPopup(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: nil, message: "How many stamps do you want to add?", preferredStyle: .alert)
        alert.setValue(pickerContainerView, forKey: "contentViewController")
        alert.addTextField { field in
            field.isSecureTextEntry = true
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

extension StampViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberOfStampsToAdd = row + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 9
    }
}

// MARK: Actions

extension StampViewController {
    @IBAction func didTapCard(_ sender: Any) {
        showInputPopup() { [weak self] input in
            guard let strongSelf = self else { return }
            if input == StampViewController.starPassword {
                strongSelf.user?.addStamp(strongSelf.numberOfStampsToAdd)
                strongSelf.refresh()
            } else if input.count > 0 {
                UIAlertController.show(title: "Sorry", message: "The password was wrong.", on: strongSelf)
                strongSelf.numberOfStampsToAdd = 0
            }
        }
    }

    @IBAction func didTapEarnedDrinksButton(_ sender: Any) {
        // show alert with to redeem drinks
        UIAlertController.show(title: "", message: "Do you want to redeem a free drink?", on: self, shouldAddCancelButton: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.user?.redeem()
            strongSelf.refresh()
        }
    }

    @IBAction func didTapLogout(_ sender: Any) {
        signout()
    }
}

// MARK: Stamp Management

extension StampViewController {
    private func refresh() {
        guard let user = user else { return }
        greetingLabel.text = greeting + " \(user.name).\n" + punchCardStatus
        earnedDrinksButton.isHidden = user.numberOfDrinksToRedeem == 0
        earnedDrinksButton.setTitle("\(user.numberOfDrinksToRedeem)", for: .normal)

        for (index, star) in stars.enumerated() {
            if index <= user.numberOfStars - 1 {
                star.tintColor = .white
                star.isHidden = false
            } else {
                star.isHidden = true
            }
        }
    }
}
