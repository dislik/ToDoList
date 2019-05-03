//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by Irina Makarova on 07.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

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
                let newCategory = Category()
                newCategory.name = text
                newCategory.colour = UIColor.randomFlat.hexValue()
                
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No Categories Added Yet"
        guard let hexColor = category?.colour, let backgroundColor = UIColor(hexString: hexColor) else {
            fatalError()
        }
        cell.backgroundColor = backgroundColor
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor, returnFlat: true)
    
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

    func loadCategories() {
        print("in  CategoryViewController.loadCategories")
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        guard let cellForDeletion = categories?[indexPath.row] else { return }
        do {
            try realm.write {
                realm.delete(cellForDeletion)
            }
            //tableView.reloadData() leads to exception SIGABRT
        } catch {
            print("Error while deleting the category \(cellForDeletion.name): \(error)")
        }
    }
    // MARK: - Navigation
}
