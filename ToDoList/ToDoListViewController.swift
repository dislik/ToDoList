//
//  ViewController.swift
//  ToDoList
//
//  Created by Irina Makarova on 01.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = ["Find Mike", "Buy Eggs", "Destroy Demogorgon"]
    let itemArrayStoreName = "ToDoListValues"
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let initArray = defaults.array(forKey: itemArrayStoreName) as? [String] {
        //if initArray.count > 0 {
            itemArray = initArray
        }
    }

    //MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
        if cell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
           cell?.accessoryType = UITableViewCell.AccessoryType.none
        } else {
           cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        //let text = cell?.textLabel?.text ?? ""  //itemArray[indexPath.row]
        //print("You've clicked on:  \(indexPath.row). \(text)")
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            guard let text = textField.text else { return }
            //what will happen once the user clicks the Add Item button on out UIAlert
            if (!text.isEmpty) {
                self.itemArray.append(text)
                self.defaults.set(self.itemArray, forKey: self.itemArrayStoreName)
                
                self.tableView.reloadData()
                //print("Smth had to be added: \(text)")
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

