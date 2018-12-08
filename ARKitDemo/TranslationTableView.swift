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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! TranslationTableViewCell

        cell.sourceWordLabel.text = "Camera"
        cell.targetWordLabel.text = "Kamera"
        cell.labeledImage.image = UIImage(named: "camera")
        cell.layoutSubviews()

        return cell
    }
    var count = 15

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? count : 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let languages = translations.keys
        guard section < languages.count else { return "Get Labeling!" }
        let index = languages.index(translations.startIndex, offsetBy: section)
        guard
            languages.indices.contains(index),
            let language = LanguageViewController.langDict.allKeys(forValue: languages[index]).first
        else { return "Get Labeling!" }
        return language
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TranslationTableViewCell
        let labeledImageVC = LabeledImageViewController()

        labeledImageVC.sourceWordLabel = cell.sourceWordLabel
        labeledImageVC.translatedWordLabel = cell.sourceWordLabel
        labeledImageVC.labeledImage = cell.labeledImage

        self.performSegue(withIdentifier: "gg", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "gg",
            let indexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: indexPath) as? TranslationTableViewCell,
            let labeledImageVC = segue.destination as? LabeledImageViewController
        else { return }

        labeledImageVC.sourceWord = cell.sourceWordLabel.text
        labeledImageVC.translatedWord = cell.sourceWordLabel.text
        labeledImageVC.image = cell.labeledImage.image
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
