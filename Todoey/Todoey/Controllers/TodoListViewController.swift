//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Никита Игумнов on 28.02.2021.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private var itemArray = [Item]()
    private let context = CoreDataContainer().context
    
    private var predicate : NSPredicate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: String(describing: TableViewCell.self), bundle: nil), forCellReuseIdentifier: "TodoItemCell")
        
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadItems()
    }
    
    @IBAction func inProgressOnlyTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
            predicate = NSPredicate(format: "inProgress = %@", "0")
        } else if sender.selectedSegmentIndex == 1 {
            predicate = NSPredicate(format: "inProgress = %@", "1")
        } else {
            predicate = nil
        }
        
        loadItems()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCreationScreenIdentifier") {
            
            let destinationVC = segue.destination as! CreateTodoViewController
            
            destinationVC.context = context
        } else if (segue.identifier == "showToEdit") {
            
            let destinationVC = segue.destination as! CreateTodoViewController
            let item = itemArray[(sender as! IndexPath).row]
            
            destinationVC.context = context
            destinationVC.item = item
        }
    }
    
    
    // MARK: - private functionality
    
    private func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        if let predicateUnwrapped = predicate {
            request.predicate = predicateUnwrapped
        }
        
        do {
            itemArray = try context.fetch(request)
            
            tableView.reloadData()
        } catch {
            print("Error fetching data from contect \(error)")
        }
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! TableViewCell
        
        let item = itemArray[indexPath.row]
        
        cell.titleLabel!.text = item.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yyyy hh:mm"
        dateFormatter.locale = Locale.init(identifier: "ru")
        cell.dateLabel!.text = dateFormatter.string(from: item.date!)
        
        cell.accessoryType = item.inProgress ? .checkmark : .none
        
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Done") { (ac, view, completion) in
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.saveItems()
        }])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showToEdit", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Search bar Methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        loadItems()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            predicate = nil
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
