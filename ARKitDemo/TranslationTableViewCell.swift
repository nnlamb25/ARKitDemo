//
//  TranslationTableViewCell.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 12/2/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import Foundation
import UIKit

class TranslationTableViewCell: UITableViewCell {
    @IBOutlet var sourceWordLabel: UILabel!
    @IBOutlet var translatedWordLabel: UILabel!
    @IBOutlet var labeledImage: UIImageView!

    var filePath: String!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        return
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        return
    }
}
