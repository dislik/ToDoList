//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Irina Makarova on 01.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    let realm = try! Realm()

    var toDoItems: Results<Item>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let DATA_FILE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        print("DATA_FILE_PATH: \(DATA_FILE_PATH)")
        */
        //searchBar.delegate = self
    }

    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ToDoListViewController:      cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            print("cell.textLabel: item != nil")
            cell.accessoryType = item.done ? .checkmark : .none
            cell.textLabel?.text = item.title
        } else {
            print("cell.textLabel: item == nil && \(cell.textLabel != nil)")
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ToDoListViewController:      didSelectRowAt")
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving data status, \(error)")
            }
        }
        //updating the field:
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        //or
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //delete the item
        //let item = itemArray[indexPath.row]
        //context.delete(item)
        //items.remove(at: indexPath.row) //it's necessary for correct data viewing

        //saveDataTo(items)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("ToDoListViewController:      addButtonPressed")
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            guard let text = textField.text else { return }
            //what will happen once the user clicks the Add Item button on out UIAlert
            if (!text.isEmpty) {
                if let currentCategory = self.selectedCategory {
                    do {
                        let newItem = Item()
                        newItem.title = text
                        newItem.done = false
                        newItem.dateCreated = Date()
                        
                        try self.realm.write {
                            currentCategory.items.append(newItem)
                            self.realm.add(newItem)
                        }
                        
                        self.tableView.reloadData()
                    } catch {
                        print("Error saving new item: \(error)")
                    }
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    func saveItem(item: Item) {
        /*
        do {
            //try context.save()
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving new item")
        }
        */
        tableView.reloadData()
    }

    func loadItems() { //with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        print("in  ToDoListViewController.loadItems")
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("in  textDidChange ")
        if let searchText = searchBar.text {
            print("in  textDidChange :  searchText = \(searchText)")
            if !searchText.isEmpty {
                toDoItems = selectedCategory?.items.filter("%K CONTAINS[cd] %@", "title", searchText)//.sorted(byKeyPath: "title", ascending: true)
                .sorted(byKeyPath: "dateCreated", ascending: true)
                tableView.reloadData()
            } else {
                loadItems()
            }
            /*let request : NSFetchRequest<Item> = Item.fetchRequest()
            var predicate : NSPredicate?
            
                predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "title", searchText)
                
                let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
                request.sortDescriptors = [sortDescriptor]
            } else {
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()    
                }
            }
             loadItems(with: request, predicate: predicate)
            */
        } else {
            print("What do you want to say by this ?")
        }
    }
}
