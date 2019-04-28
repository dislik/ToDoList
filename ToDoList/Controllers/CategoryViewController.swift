//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by Irina Makarova on 07.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            guard let text = textField.text else { return }
            if !text.isEmpty {
                //let newCategory = Category(name: text)
                
                let newCategory = Category()
                newCategory.name = text
                
                self.save(category: newCategory)
            }
        }

        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ToDoListViewController
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    // MARK: - Data Manipulation Methods
    func save(category: Category) {
        do {
            try self.realm.write {
                self.realm.add(category)
            }
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        tableView.reloadData()
    }

    func loadCategories(/*with request : NSFetchRequest<Category> = Category.fetchRequest()*/) {
        print("in  CategoryViewController.loadCategories")
        categories = realm.objects(Category.self)
        /*
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        */
        tableView.reloadData()
    }
    // MARK: - Navigation
}
