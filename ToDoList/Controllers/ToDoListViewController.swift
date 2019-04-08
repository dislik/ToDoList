//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Irina Makarova on 01.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.accessoryType = item.done ? .checkmark : .none
        cell.textLabel?.text = item.title
        
        
        return cell
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ToDoListViewController:      didSelectRowAt")
        
        //updating the field:
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        //or
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //delete the item
        let item = itemArray[indexPath.row]
        context.delete(item)
        itemArray.remove(at: indexPath.row) //it's necessary for correct data viewing

        saveDataTo(itemArray)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("in addButtonPressed")
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            guard let text = textField.text else { return }
            //what will happen once the user clicks the Add Item button on out UIAlert
            if (!text.isEmpty) {
                let item = Item(context: self.context)
                item.title = text
                item.done = false
                item.parentCategory = self.selectedCategory
                
                self.itemArray.append(item)
                self.saveDataTo(self.itemArray)
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
    func saveDataTo(_ data: [Item]) {
        do {
            try context.save()
        } catch {
            print("Error saving data array")
        }
        
        tableView.reloadData()
    }

    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        do {
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            
            if predicate != nil {
                 request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate!])
            } else {
                 request.predicate = categoryPredicate
            }
            
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            var predicate : NSPredicate?
            if !searchText.isEmpty {
                predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "title", searchText)
                
                let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
                request.sortDescriptors = [sortDescriptor]
            } else {
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()    
                }
            }
            loadItems(with: request, predicate: predicate)
        } else {
            print("What do you want to say by this ?")
        }
    }
}
