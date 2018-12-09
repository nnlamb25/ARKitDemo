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

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return labelType.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return labelType[row]
    }
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var horizontalColorPicker: SwiftHUEColorPicker!
    
    @IBOutlet weak var typePicker: UIPickerView!
    
    
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        colorView.backgroundColor = color
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Color Picker"
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        

        horizontalColorPicker.delegate = self
        horizontalColorPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal        
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
