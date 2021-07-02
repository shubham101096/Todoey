//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Shubham Mishra on 28/02/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    var addCategoryAlert = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCategories()
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        if let navBarColour = UIColor(hexString: "1d9bf6") {
            navBar.backgroundColor = navBarColour
            navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        }
    }
    
    //MARK: Table View Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            guard let hexBgColor = UIColor(hexString: category.bgColor) else {fatalError()}
            cell.backgroundColor = hexBgColor
            cell.textLabel?.textColor = ContrastColorOf(hexBgColor, returnFlat: true)

        }

        return cell
    }
    
    //MARK: Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItem" {
            let destinationVC = segue.destination as! TodoListViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                destinationVC.selectedCategory = categoryArray?[row]
            }
        }
    }
    
    //MARK: Add new categories
    
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        addCategoryAlert = UIAlertController(title: "Add category", message: nil, preferredStyle: .alert)
        var textField = UITextField()
        textField.delegate = self
        addCategoryAlert.addTextField { (categoryTextField) in
            categoryTextField.placeholder = "Enter new category"
            textField = categoryTextField
        }
        textField.addTarget(self, action: #selector(self.alertTextFieldDidChange), for: .allEditingEvents)
        let saveAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let text = textField.text {
                let category = Category()
                category.name = text
                category.bgColor = UIColor.randomFlat().hexValue()
                self.saveCategories(newCategory: category)
            }
        }
        saveAction.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addCategoryAlert.addAction(saveAction)
        addCategoryAlert.addAction(cancelAction)
        present(addCategoryAlert, animated: true, completion: nil)
    }
    
    //MARK: Data Manipulation Methods
    
    func saveCategories(newCategory: Category) {
        do {
            try realm.write {
                self.realm.add(newCategory)
            }
            tableView.reloadData()
        } catch {
            print("Error saving categories: \(error)")
        }
    }
    
    func loadCategories() {
            categoryArray = realm.objects(Category.self)
            tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = categoryArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }
    
}

//MARK: - Text field delegates

extension CategoryTableViewController: UITextFieldDelegate {
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        if let text = sender.text {
            addCategoryAlert.actions[0].isEnabled = text.isEmpty ? false : true
        }
    }
}
