//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var itemArray: Results<Item>?
    var alert: UIAlertController?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = itemArray?[indexPath.row]
        cell.textLabel?.text = item?.title ?? "No item added yet"
        if let done = item?.done {
            cell.accessoryType = done ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch  {
                print("Error updating item: \(error)")
            }
        }
        tableView.reloadData()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Remove", handler: { (_, _, _) in
            
            if let item = self.itemArray?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                    
                } catch {
                    print("Error deleting item")
                }
                self.tableView.deleteRows(at: [indexPath], with: .top)
            }
        })])
    }
    
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        alert = UIAlertController(title: "Add", message: "Enter item", preferredStyle: .alert)
        alert?.addTextField { (itemTextField) in
            itemTextField.placeholder = "New item"
            itemTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
            textField = itemTextField
        }
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let itemText = textField.text {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = itemText
                            newItem.date = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving data: \(error)")
                    }
                    self.tableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
    
        alert?.addAction(saveAction)
        alert?.addAction(cancelAction)
        saveAction.isEnabled = false
        
        present(alert!, animated: true, completion: nil)
    }
    
    func loadItems() {
            itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
            tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.itemArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
                
            } catch {
                print("Error deleting item \(error)")
            }
        }
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[0].isEnabled = sender.text!.isEmpty ? false : true
    }
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        itemArray = itemArray?.filter(predicate).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadItems()
        DispatchQueue.main.async {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }
}

