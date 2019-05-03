//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Irina Makarova on 01.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    var toDoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!

    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        //let DATA_FILE_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        //print("DATA_FILE_PATH: \(DATA_FILE_PATH)")
    }

    override func viewWillAppear(_ animated: Bool) {
        
        guard let hexColor = selectedCategory?.colour else {
            fatalError("SelectedCategory.colour is empty !")
        }
        updateNavigationBar(withHexCode: hexColor)
        searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        
        title = selectedCategory!.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavigationBar(withHexCode: "28AAC0")
        
        //navBar.tintColor = FlatWhite()
        //navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : FlatWhite()]
    }
    
    //MARK: - Navigation Bar Setup Methods
    func updateNavigationBar(withHexCode hexColor: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist.")
        }
        guard let barTintColor = UIColor(hexString: hexColor) else {
            fatalError("Couldn't determine the color by hexString \(hexColor).")
        }
        
        navBar.barTintColor = barTintColor
        navBar.tintColor = ContrastColorOf(barTintColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(barTintColor, returnFlat: true)]
    }
    
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.accessoryType = item.done ? .checkmark : .none
            cell.textLabel?.text = item.title
            if let hexColor = selectedCategory?.colour {
                cell.backgroundColor = UIColor(hexString: hexColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count + 2))
                cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            }
        } else {
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
        tableView.reloadData()
    }

    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        guard let cellForDeletion = selectedCategory?.items[indexPath.row] else { return }
        do {
            try realm.write {
                realm.delete(cellForDeletion)
            }
            //tableView.reloadData() leads to exception SIGABRT
        } catch {
            print("Error while deleting the item \(cellForDeletion.title): \(error)")
        }
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
        } else {
            print("What do you want to say by this ?")
        }
    }
}
