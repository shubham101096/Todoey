//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
        
    var itemArray = ["code", "code again", "take rest", "decode", "become champion"]
    var alert: UIAlertController?
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        itemArray = defaults.array(forKey: "TodoListArray") as? [String] ?? itemArray
//        self.tableView.setEditing(true, animated: true)
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = String(itemArray[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        if self.tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.none {
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        
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
                self.itemArray.append(itemText)
                self.defaults.setValue(self.itemArray, forKey: "TodoListArray")
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
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[0].isEnabled = sender.text!.isEmpty ? false : true
    }
    
}

