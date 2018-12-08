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

    override func viewDidLoad() {
        sourceWordLabel.text = sourceWord
        translatedWordLabel.text = translatedWord
        labeledImage.image = image
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
}
