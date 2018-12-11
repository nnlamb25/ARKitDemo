//
//  ColorPickerViewController.swift
//  ARKitDemo
//
//  Created by Hao Dang on 12/8/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController, SwiftHUEColorPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let labelType = ["Original Text","Translated Text"]
    var pickerName = ""

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return labelType.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return labelType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerName = labelType[row] as String
    }
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var horizontalColorPicker: SwiftHUEColorPicker!
    
    @IBOutlet weak var typePicker: UIPickerView!
    
    
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        colorView.backgroundColor = color
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerName = labelType[0]
        self.title = "Color Picker"
        self.typePicker.delegate = self
        self.typePicker.dataSource = self

        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(tapButtion))
        self.navigationItem.rightBarButtonItem = saveButton

        horizontalColorPicker.delegate = self
        horizontalColorPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal        
        // Do any additional setup after loading the view.
    }
    
    @objc func tapButtion() {
        if (pickerName == "Original Text") {
            ColorLabel.originalText = colorView.backgroundColor!
        }
        
        if (pickerName == "Translated Text") {
            ColorLabel.translatedText = colorView.backgroundColor!
        }
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
