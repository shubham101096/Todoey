//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
        
    var itemArray = [Item]()
    var alert: UIAlertController?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        self.tableView.deselectRow(at: indexPath, animated: true)
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
                let newItem = Item(context: self.context)
                newItem.title = itemText
                newItem.done = false
                self.itemArray.append(newItem)
                self.saveItems()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
    
        alert?.addAction(saveAction)
        alert?.addAction(cancelAction)
        saveAction.isEnabled = false
        
        present(alert!, animated: true, completion: nil)
    }
    
    func saveItems() -> Void {
                
        do {
            try context.save()
            self.tableView.reloadData()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error while saving: \(nserror), \(nserror.userInfo)")
        }
    }
    
    func loadItems() {
        let request :NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error loading items: \(error)")
        }
        
        
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[0].isEnabled = sender.text!.isEmpty ? false : true
    }
    
}

