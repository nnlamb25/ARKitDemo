//
//  SecondViewController.swift
//  ARKitDemo
//
//  Created by Hao Dang on 11/29/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBAction func selectLang(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let langVC = storyboard.instantiateViewController(withIdentifier: "LanguageViewController") as! LanguageViewController
        self.navigationController?.pushViewController(langVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"

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
