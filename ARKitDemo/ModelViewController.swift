//
//  LanguageViewController.swift
//  ARKitDemo
//
//  Created by Hao Dang on 11/29/18.
//  Copyright © 2018 nnlamb25. All rights reserved.
//

import UIKit

class ModelViewController: UIViewController {

    let modelNameArr = ["Office", "Pets"]
    
    var searchedModel = [String]()
    var searching = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Model"
        self.tbView.delegate = self
        self.tbView.dataSource = self
        
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

extension ModelViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedModel.count
        } else {
            return modelNameArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if searching {
            cell.textLabel?.text = searchedModel[indexPath.row]
        } else {
            cell.textLabel?.text = modelNameArr[indexPath.row]
        }
        
        if (cell.textLabel?.text == SelectedMLModel.model) {
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
        
        SelectedMLModel.model = currentItem ?? "Office"
        SelectedMLModel.indexPath = (indexPath?.row)!
        
        currentCell.accessoryType = .checkmark
        tableView.reloadData()
    }
    
}

extension ModelViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedModel = modelNameArr.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
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
