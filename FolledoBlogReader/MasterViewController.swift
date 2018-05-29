//
//  MasterViewController.swift
//  FolledoBlogReader
//
//  Created by Samuel Folledo on 5/10/18.
//  Copyright © 2018 Samuel Folledo. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate { //1

    var detailViewController: DetailViewController? = nil //1
    var managedObjectContext: NSManagedObjectContext? = nil //1


    override func viewDidLoad() { //1
        super.viewDidLoad() //1
/* //1
        navigationItem.leftBarButtonItem = editButtonItem //1

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:))) //1
        navigationItem.rightBarButtonItem = addButton //1
        if let split = splitViewController { //1
            let controllers = split.viewControllers //1
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController //1
       } //1
 */
        //viewDidLoad()
        let url = URL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyBTFFsGSjMWCkqQyJP2-x9qATz2Kjof_HM")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
//                    print(urlContent) //prints how many bytes
                    
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject //step need to actually see the URL codes
                        //print(jsonResult)
                        
                        if let items = jsonResult["items"] as? NSArray {

                            let context = self.fetchedResultsController.managedObjectContext //1
                            let request = NSFetchRequest<Event>(entityName: "Event") //30 mins
                            do {
                                let results = try context.fetch(request) //fetch our results, which is everything in Events table
                                if results.count > 0 {
                                    for result in results { //if count > 0 then loop through results and delete. Dont need to cast as we already said it will be an <Event>
                                        context.delete(result)
                                        
                                        do { //32 mins
                                            try context.save()
                                        } catch { print("Specific delete failed") }
                                    }
                                }
                            } catch { print("Delete failed") } //end of 32 mins

                            for item in items as [AnyObject] {
                                //print(item)
                                
                                //print("+++++\(item["published"])+++++")
                                //print("+++++\(item["title"])+++++")
                                //print("+++++\(item["content"])+++++")
                                
                                //now that we have item's published, title, and content, we save them in CoreData, take it from insertNewObject method
                                //let context = self.fetchedResultsController.managedObjectContext //1 //moved to before for in loop
                                let newEvent = Event(context: context) //1
                                
                                // If appropriate, configure the new managed object.
                                newEvent.timestamp = Date() //1
                                newEvent.setValue(item["published"] as! String, forKey: "published")//we can use ! because we know it will exist
                                newEvent.setValue(item["title"] as! String, forKey: "title")
                                newEvent.setValue(item["content"] as! String, forKey: "content")
                                
                                // Save the context
                                do { //1
                                    try context.save() //1
                                } catch { //1
                                    // Replace this implementation with code to handle the error appropriately.
                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                    let nserror = error as NSError //1
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)") //1

                                }
                            }
                            
                            //26 mins. Once save is done, we'll update the table. But as you remember we're not currently in the main queue here because we're doing asynchrous requests download content from the web and any user interface updates including reloading the table should be done in the main queue
                            DispatchQueue.main.async(execute: { //any code here are run after saving. This is where we would write how user interface updates including reloading our table date
                                self.tableView.reloadData()
                                
                            })
                            
                        }
                        
                    } catch { print("JSON Processing Failed") }
                }
            }
            
        }
        task.resume()
        
        
    }

//    override func viewWillAppear(_ animated: Bool) { //1
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
//        super.viewWillAppear(animated) //1
//    } //1

    override func didReceiveMemoryWarning() { //1
        super.didReceiveMemoryWarning() //1
        // Dispose of any resources that can be recreated.
    }

    @objc func insertNewObject(_ sender: Any) { //1
        let context = self.fetchedResultsController.managedObjectContext //1
        let newEvent = Event(context: context) //1
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = Date() //1

        // Save the context
        do { //1
            try context.save() //1
        } catch { //1
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError //1
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)") //1
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //1 //Essentially for getting the indexPath for the selected row and then sending the object from CoreData to the detail view controller, and then setting up the back button on the detail view controller
        if segue.identifier == "showDetail" { //1
            if let indexPath = tableView.indexPathForSelectedRow { //1
            let object = fetchedResultsController.object(at: indexPath) //1
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController //1
                controller.detailItem = object //1
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem //1
                controller.navigationItem.leftItemsSupplementBackButton = true //1
            }
        }
    }

    
    //------------------ MARK: - Table View ----------------------
    override func numberOfSections(in tableView: UITableView) -> Int { //1 //gets the number directly from fetchedResultsController which gets the result from CoreData directly
        return fetchedResultsController.sections?.count ?? 0 //1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //1
        let sectionInfo = fetchedResultsController.sections![section] //1
        return sectionInfo.numberOfObjects //1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //1
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //1
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event) //1
        return cell //1
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { //1
        return false //1 //false to make item uneditable
    }

/* //1 //allows user to delete stuff from the table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
*/
    
//configure the cell
    func configureCell(_ cell: UITableViewCell, withEvent event: Event) { //1 //called in cellForRowAt
        //cell.textLabel!.text = event.timestamp!.description //1
        
        cell.textLabel!.text = event.value(forKey: "title") as? String //28 mins.
        
    } //1

    
    //------------- MARK: - Fetched results controller ------------
    var fetchedResultsController: NSFetchedResultsController<Event> { //1
        if _fetchedResultsController != nil { //1 //manages the core data for us and allows us to separate out all of the nasty core data code from things like our table view creation
            return _fetchedResultsController! //1
        } //1
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest() //1
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20 //1 //restricts the number of results to a particular number
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "published", ascending: false) //1 //sort descriptor which changes the order of the results //37:15 mins to have it be sorted by newest published blog
        
        fetchRequest.sortDescriptors = [sortDescriptor] //1
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master") //1
        aFetchedResultsController.delegate = self //1
        _fetchedResultsController = aFetchedResultsController //1
        
        do { //1
            try _fetchedResultsController!.performFetch() //1
        } catch { //1
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError //1
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)") //1
        }
        return _fetchedResultsController! //1
    } //1
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil //1

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //1
        tableView.beginUpdates() //1
    } //1

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) { //1
        switch type { //1
            case .insert: //1
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade) //1
            case .delete: //1
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade) //1
            default: //1
                return //1
        } //1
    } //1

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) { //1
        switch type { //1
            case .insert: //1
                tableView.insertRows(at: [newIndexPath!], with: .fade) //1
            case .delete: //1
                tableView.deleteRows(at: [indexPath!], with: .fade) //1
            case .update: //1
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event) //1
            case .move: //1
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event) //1
                tableView.moveRow(at: indexPath!, to: newIndexPath!) //1
        } //1
    } //1

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //1
        tableView.endUpdates() //1
    }

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
*/

}

