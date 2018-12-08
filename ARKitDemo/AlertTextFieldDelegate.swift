//
//  AlertTextFieldDelegate.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 12/7/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import Foundation
import UIKit

class AlertTextFieldDelegate: NSObject, UITextFieldDelegate {

    private let maxCharactersAllowedForLabel = 20

    // Ensures user cannot enter in an empty string
    func textFieldDidChange(_ sender: UITextField) -> Bool {
        guard let count = sender.text?.replacingOccurrences(of: " ", with: "").count else {
            return true
        }

        return count > 0
    }
    
    // Ensures user cannot enter in too many characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        guard range.length + range.location <= currentCharacterCount else { return false}
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= maxCharactersAllowedForLabel
    }
}
