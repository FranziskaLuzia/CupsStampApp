//
//  UIAlertController+Show.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/28/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit

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
