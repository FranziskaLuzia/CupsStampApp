//
//  Spinner.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/29/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//

import UIKit

final class Spinner: UIActivityIndicatorView {
    init() {
        super.init(frame: .zero)
        isHidden = true
        hidesWhenStopped = true
        style = .gray
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func show() {
        startAnimating()
        isHidden = false
    }

    func hide() {
        stopAnimating()
    }
}
