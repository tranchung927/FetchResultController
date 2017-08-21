//
//  TableViewController.swift
//  FetchResultController
//
//  Created by Chung Sama on 8/14/17.
//  Copyright © 2017 Chung Sama. All rights reserved.
//

import UIKit
import CoreData

class MasterController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Person> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementtation with code to handle the error appropriately
            // fatalError() causes the application to generate a crash to log and terminate. You should not use this function in a shipping application, although it may be useful during development
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Person>? = nil
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addName))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let person = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withPerson: person)
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withPerson person: Person) {
        cell.textLabel?.text = person.name!.description
    }
    
    
    // MARK: - Action add new name
    @objc func addName() {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            
            let context = self.fetchedResultsController.managedObjectContext
            
            let newPerson = Person(context: context)
            // If appropriate, configure the new managed object.
            newPerson.name = nameToSave
            
            // Save the context
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! DetailViewController
                controller.person = object
            }
        }
    }
    // MARK: - FetchedResultsController delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withPerson: anObject as! Person)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withPerson: anObject as! Person)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
