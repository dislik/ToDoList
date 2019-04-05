//
//  ViewController.swift
//  ToDoList
//
//  Created by Irina Makarova on 01.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    let itemArrayStoreName = "ToDoListValues"
    let DATA_FILE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //don't use it      let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("DATA_FILE_PATH: \(DATA_FILE_PATH)")
        
        //if let items = defaults.object(forKey: itemArrayStoreName) as? [Item] {
            //itemArray = items
        //} else {
        //itemArray = [Item("Find Mike", false), Item("Buy Eggs", false), Item("Destroy Demogorgon", false)]
        loadItems()
        //}
    }

    //MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.accessoryType = item.done ? .checkmark : .none
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ToDoListViewController:      didSelectRowAt")
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveDataTo(itemArray, path: DATA_FILE_PATH!)
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            guard let text = textField.text else { return }
            //what will happen once the user clicks the Add Item button on out UIAlert
            if (!text.isEmpty) {
                self.itemArray.append(Item(text, false))
                //self.defaults.set(self.itemArray, forKey: self.itemArrayStoreName)
                
                self.saveDataTo(self.itemArray, path: self.DATA_FILE_PATH!)
                
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
    
    //saveDataTo(self.itemArray, self.DATA_FILE_PATH!)
    func saveDataTo(_ data: [Encodable], path: URL) {
        let encoder = PropertyListEncoder()
        
        do {
            //let encodeData = try encoder.encode(data)
            let encodeData = try encoder.encode(itemArray)
            try encodeData.write(to: path)
        } catch {
            print("Error encoding data array")
        }
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: DATA_FILE_PATH!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("The error has happened while decoding data from Property List...")
            }
        }
    }
}
