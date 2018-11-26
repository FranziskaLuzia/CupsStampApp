//
//  StampViewController.swift
//  CupsStampApp
//
//  Created by Franziska Kammerl on 11/13/18.
//  Copyright © 2018 Franziska Kammerl. All rights reserved.
//


import UIKit

//class StampViewController: UIView {
//
//    lazy var filter = CIFilter(name: "CIQRCodeGenerator")
//    lazy var imageView = UIImageView().withRenderingMode(.alwaysTemplate)
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let frame = CGRect(origin: .zero, size: .init(width: 320, height: 320))
//        let view = QRCodeView(frame: frame)
//        view.generateCode("http://itch.design",
//                          foregroundColor: UIColor(red:1.00, green:0.02, blue:0.35, alpha:1.00),
//                          backgroundColor: UIColor(red:1.00, green:0.82, blue:0.86, alpha:1.00))
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addSubview(imageView)
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        imageView.frame = bounds
//    }
//
//    func generateCode(_ string: String, foregroundColor: UIColor = .black, backgroundColor: UIColor = .white) {
//        guard let filter = filter,
//            let data = string.data(using: .isoLatin1, allowLossyConversion: false) else {
//                return
//        }
//
//        filter.setValue(data, forKey: "inputMessage")
//
//        guard let ciImage = filter.outputImage else {
//            return
//        }
//
//        let transformed = ciImage.transformed(by: CGAffineTransform.init(scaleX: 10, y: 10))
//        let invertFilter = CIFilter(name: "CIColorInvert")
//        invertFilter?.setValue(transformed, forKey: kCIInputImageKey)
//
//        let alphaFilter = CIFilter(name: "CIMaskToAlpha")
//        alphaFilter?.setValue(invertFilter?.outputImage, forKey: kCIInputImageKey)
//
//        if let outputImage = alphaFilter?.outputImage  {
//            imageView.tintColor = foregroundColor
//            imageView.backgroundColor = backgroundColor
//            imageView.image = UIImage(ciImage: outputImage, scale: 2.0, orientation: .up)
//                .withRenderingMode(.alwaysTemplate)
//        }
//    }
//}
