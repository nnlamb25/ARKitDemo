//
//  TranslationTable.swift
//  ARKitDemo
//
//  Created by Nathan Lamb on 12/2/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import Foundation
import UIKit

class TranslationTableView: UITableViewController {

    var translations = UserDefaults.standard.dictionary(forKey: "translations") as? [String: [String: String]] ?? [String: [String: String]]()
    var imagesAndLabels = [(image: UIImage, label: String)]()

    // Populates imagesAndLabels from storage
    override func viewDidLoad() {
        setUpTable()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpTable()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! TranslationTableViewCell

        let index = indexPath.row
        let language = UserDefaults.standard.string(forKey: "languageValue")
        cell.sourceWordLabel.text = imagesAndLabels[index].label
        cell.labeledImage.image = imagesAndLabels[index].image

        if let languageKey = language,
            let translatedWord = translations[languageKey]?[imagesAndLabels[index].label] {
            cell.translatedWordLabel.text = translatedWord
        } else {
            cell.translatedWordLabel.text = ""
            let params = ROGoogleTranslateParams(source: "en", target: LanguageAPI.languageValue, text: imagesAndLabels[index].label)
            ROGoogleTranslate.translate(params: params, guarded: false) { translation in
                DispatchQueue.main.async {
                    cell.translatedWordLabel.text = translation
                }
            }
        }

        cell.layoutSubviews()

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let count = try? FileManager.default.contentsOfDirectory(atPath: documentPath.path).count
        else { return 0 }
        return count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TranslationTableViewCell
        let labeledImageVC = LabeledImageViewController()

        labeledImageVC.sourceWordLabel = cell.sourceWordLabel
        labeledImageVC.translatedWordLabel = cell.sourceWordLabel
        labeledImageVC.labeledImage = cell.labeledImage

        self.performSegue(withIdentifier: "selectedImage", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "selectedImage",
            let indexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: indexPath) as? TranslationTableViewCell,
            let labeledImageVC = segue.destination as? LabeledImageViewController
        else { return }

        labeledImageVC.sourceWord = cell.sourceWordLabel.text
        labeledImageVC.translatedWord = cell.translatedWordLabel.text
        labeledImageVC.image = cell.labeledImage.image
    }

    private func setUpTable() {
        guard
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let imagePathLabels = UserDefaults.standard.dictionary(forKey: StorageController.imagePathKey) as? [String: String]
        else { return }
        
        for (path, label) in imagePathLabels {
            guard
                let imageData = FileManager.default.contents(atPath: documentPath.appendingPathComponent(path).path),
                let uiImage = UIImage(data: imageData),
                let cgImage = uiImage.cgImage
                else {
                    print("Could not convert image data at path: \(path) to image")
                    return
            }
            // Need to orient the image correctly
            let image = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .right)
            imagesAndLabels.append((image, label))
        }
        
        // Sorts alphabetically by label
        imagesAndLabels.sort(by: { $0.label < $1.label })
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle:
//        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            count -= 1
//            self.translations.removeValue(forKey: "bs")
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }

//    @IBAction func deleteCell(_ sender: UIButton) {
//        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
//        guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else { return }
//        count -= 1
//        self.translations.removeValue(forKey: "bs")
//        tableView.deleteRows(at: [indexPath], with: .fade)
//    }
}
