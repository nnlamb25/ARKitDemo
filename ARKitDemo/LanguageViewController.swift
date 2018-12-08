//
//  LanguageViewController.swift
//  ARKitDemo
//
//  Created by Hao Dang on 11/29/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
    static let langDict = ["Afrikaans" :    "af",
                           "Albanian" :    "sq",
                           "Amharic" :    "am",
                           "Arabic" :    "ar",
                           "Armenian" :    "hy",
                           "Azerbaijani" :    "az",
                           "Basque" :    "eu",
                           "Belarusian" :    "be",
                           "Bengali" :    "bn",
                           "Bosnian" :    "bs",
                           "Bulgarian" :    "bg",
                           "Catalan" :    "ca",
                           "Cebuano" :    "ceb",
                           "Chinese (Simplified)" : "zh-CN",
                           "Chinese (Traditional)" : "zh-TW",
                           "Corsican" :    "co",
                           "Croatian" :    "hr",
                           "Czech" :    "cs",
                           "Danish" :    "da",
                           "Dutch" :    "nl",
                           "English" :    "en",
                           "Esperanto" :    "eo",
                           "Estonian" :    "et",
                           "Finnish" :    "fi",
                           "French" :    "fr",
                           "Frisian" :    "fy",
                           "Galician" :    "gl",
                           "Georgian" :    "ka",
                           "German" :    "de",
                           "Greek" :    "el",
                           "Gujarati" :    "gu",
                           "Haitian" : "le",
                           "Hausa" :    "ha",
                           "Hawaiian" :    "haw",
                           "Hebrew" :    "he",
                           "Hindi" :    "hi",
                           "Hmong" :    "hmn",
                           "Hungarian" :    "hu",
                           "Icelandic" :    "is",
                           "Igbo" :    "ig",
                           "Indonesian" :    "id",
                           "Irish" :    "ga",
                           "Italian" :    "it",
                           "Japanese" :    "ja",
                           "Javanese" :    "jw",
                           "Kannada" :    "kn",
                           "Kazakh" :    "kk",
                           "Khmer" :    "km",
                           "Korean" :    "ko",
                           "Kurdish" :    "ku",
                           "Kyrgyz" :    "ky",
                           "Lao" :    "lo",
                           "Latin" :    "la",
                           "Latvian" :    "lv",
                           "Lithuanian" :    "lt",
                           "Luxembourgish" :    "lb",
                           "Macedonian" :    "mk",
                           "Malagasy" :    "mg",
                           "Malay" :    "ms",
                           "Malayalam" :    "ml",
                           "Maltese" :    "mt",
                           "Maori" :    "mi",
                           "Marathi" :    "mr",
                           "Mongolian" :    "mn",
                           "Myanmar" : "my",
                           "Nepali" :    "ne",
                           "Norwegian" :    "no",
                           "Nyanja" : "ny",
                           "Pashto" :    "ps",
                           "Persian" :    "fa",
                           "Polish" :    "pl",
                           "Portuguese" : "pt",
                           "Punjabi" :    "pa",
                           "Romanian" :    "ro",
                           "Russian" :    "ru",
                           "Samoan" :    "sm",
                           "Scots" : "gd",
                           "Serbian" :    "sr",
                           "Sesotho" :    "st",
                           "Shona" :    "sn",
                           "Sindhi" :    "sd",
                           "Sinhala" : "si",
                           "Slovak" :    "sk",
                           "Slovenian" :    "sl",
                           "Somali" :    "so",
                           "Spanish" :    "es",
                           "Sundanese" :    "su",
                           "Swahili" :    "sw",
                           "Swedish" :    "sv",
                           "Tagalog" : "tl",
                           "Tajik" :    "tg",
                           "Tamil" :    "ta",
                           "Telugu" :    "te",
                           "Thai" :    "th",
                           "Turkish" :    "tr",
                           "Ukrainian" :    "uk",
                           "Urdu" :    "ur",
                           "Uzbek" :    "uz",
                           "Vietnamese" :    "vi",
                           "Welsh" :    "cy",
                           "Xhosa" :    "xh",
                           "Yiddish" :    "yi",
                           "Yoruba" :    "yo",
                           "Zulu" :    "zu"]
    
    var countryNameArr = [String]()
    
    var searchedCountry = [String]()
    var searching = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Languages"
        self.tbView.delegate = self
        self.tbView.dataSource = self
        countryNameArr = Array(LanguageViewController.langDict.keys).sorted()
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension LanguageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedCountry.count
        } else {
            return countryNameArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if searching {
            cell.textLabel?.text = searchedCountry[indexPath.row]
        } else {
            cell.textLabel?.text = countryNameArr[indexPath.row]
        }
        
        if (cell.textLabel?.text == languageAPI.languageKey) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        //getting the current cell from the index path
        let currentCell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
        
        //getting the text of that cell
        let currentItem = currentCell.textLabel!.text
        
        languageAPI.languageKey = currentItem ?? "Afrikaans"
        languageAPI.languageValue = LanguageViewController.langDict[currentItem!] ?? "af"
        languageAPI.indexPath = (indexPath?.row)!
        currentCell.accessoryType = .checkmark
        tableView.reloadData()
    }
}

extension LanguageViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCountry = countryNameArr.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tbView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        self.view.endEditing(true)
        tbView.reloadData()
    }
    
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue value: Value) -> [Key] {
        return self.filter { $1 == value }.map { $0.0 }
    }
}
