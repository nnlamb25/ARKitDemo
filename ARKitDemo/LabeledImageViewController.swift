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
    var filePath: String?

    @IBOutlet var sourceWordLabel: UILabel!
    @IBOutlet var translatedWordLabel: UILabel!
    @IBOutlet var labeledImage: UIImageView!

    var alertController: UIAlertController?
    let textFieldDelegate = AlertTextFieldDelegate()

    override func viewDidLoad() {
        sourceWordLabel.text = sourceWord
        translatedWordLabel.text = translatedWord
        labeledImage.image = image
    }
    @IBAction func editLabel(_ sender: UIButton) {
        self.alertController = UIAlertController(title: "Change Label", message: "What should this be labeled?", preferredStyle: .alert)
        let addLabel = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.changeLabel()
        }
        
        addLabel.isEnabled = false
        
        let cancelLabel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        self.alertController?.addTextField { textField in
            textField.delegate = self.textFieldDelegate
            textField.placeholder = "Enter label for Image"
            textField.addTarget(self, action: #selector(self.guardInputLength), for: .editingChanged)
        }
        
        self.alertController?.addAction(addLabel)
        self.alertController?.addAction(cancelLabel)
        
        guard let alert = self.alertController else { return }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func guardInputLength(_ sender: UITextField) {
        alertController?.actions[0].isEnabled = textFieldDelegate.textFieldDidChange(sender)
    }
    
    @IBAction func deleteImage(_ sender: UIButton) {
        let title: String
        if let word = sourceWord {
            title = "Delete image of \(word)?"
        } else {
            title = "Delete image?"
        }
        self.alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.removeImageFromMemory()
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        let cancelLabel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        self.alertController?.addAction(confirmAction)
        self.alertController?.addAction(cancelLabel)
        
        guard let alert = self.alertController else { return }
        
        self.present(alert, animated: true, completion: nil)
    }

    private func removeImageFromMemory() {
        guard
            let filePath = filePath,
            var imageLabelDict = UserDefaults.standard.dictionary(forKey: StorageController.imagePathKey) as? [String : String]
        else { return }
        
        imageLabelDict.removeValue(forKey: filePath)
        UserDefaults.standard.set(imageLabelDict, forKey: StorageController.imagePathKey)

        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let urlPath = documentURL.appendingPathComponent(filePath)
        do {
            try FileManager.default.removeItem(at: urlPath)
        } catch {
            print("Could not remove file at \(urlPath.absoluteString): \(error)")
        }
    }

    private func changeLabel() {
        guard
            let filePath = self.filePath,
            let label = self.alertController?.textFields?[0].text,
            var imageLabelDict = UserDefaults.standard.dictionary(forKey: StorageController.imagePathKey) as? [String : String]
        else { return }
        
        imageLabelDict[filePath] = label
        UserDefaults.standard.set(imageLabelDict, forKey: StorageController.imagePathKey)
        self.sourceWord = label
        self.translatedWord = ""
        
        DispatchQueue.main.async {
            self.translatedWordLabel.text = ""
            self.sourceWordLabel.text = label
        }
        
        let params = ROGoogleTranslateParams(source: "en", target: LanguageAPI.languageValue, text: label)
        ROGoogleTranslate.translate(params: params, guarded: false) { translation in
            DispatchQueue.main.async {
                self.translatedWordLabel.text = translation
            }
            self.translatedWord = translation
        }
    }
}
