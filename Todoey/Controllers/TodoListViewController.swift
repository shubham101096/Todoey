//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
        
    var itemArray = Array(repeating: Item(item: "code"), count: 3)
    var alert: UIAlertController?
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        loadData()
        
//        itemArray = defaults.array(forKey: "TodoListArray") as? [Item] ?? itemArray
//        self.tableView.setEditing(true, animated: true)
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.item
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.reloadData()
        
//        cell.accessor
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        alert = UIAlertController(title: "Add", message: "Enter item", preferredStyle: .alert)
        alert?.addTextField { (itemTextField) in
            itemTextField.placeholder = "New item"
            itemTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let itemText = self.alert?.textFields![0].text {
                self.itemArray.append(Item(item: itemText))
                self.saveItems()
                self.tableView.reloadData()
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
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding itemArray: \(error)")
        }
    }
    
    func loadData() -> Void {
        
        if  let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error loading data: \(error)")
            }
        }
        
//        do {
//            let data = try Data(contentsOf: dataFilePath!)
//            let decoder = PropertyListDecoder()
//            itemArray = try decoder.decode([Item].self, from: data)
//        } catch {
//            print("Error loading data: \(error)")
//        }
        
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[0].isEnabled = sender.text!.isEmpty ? false : true
    }
    
}

