//
//  LabeledImageViewController.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 12/2/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import Foundation
import UIKit

class LabeledImageViewController: UIViewController {

    var sourceWord: String!
    var translatedWord: String!
    var image: UIImage!

    @IBOutlet var sourceWordLabel: UILabel!
    @IBOutlet var translatedWordLabel: UILabel!
    @IBOutlet var labeledImage: UIImageView!

    override func viewDidLoad() {
        sourceWordLabel.text = sourceWord
        translatedWordLabel.text = translatedWord
        labeledImage.image = image
    }
}
