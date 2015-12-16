//
//  ViewController.swift
//  DBus
//
//  Created by Paolo Coronati on 01/07/2015.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

import UIKit
import ModelManager

class ViewController: UITableViewController {

    var stops = [DBBusStop]()
    
    override func viewDidLoad() {
        self.title = "Favorites"
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        super.viewDidLoad()
        DBStopsManager.sharedInstance().favorites { (result:[AnyObject]) -> Void in
            self.stops.appendContentsOf( result as! [DBBusStop])
            self.tableView.reloadData()
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addButtonPressed:"))
    }
    
    func addButtonPressed(sender: UIBarButtonItem){
        let controller = UIAlertController(title: "Insert stop number to make it fav",
                                         message: nil,
                                  preferredStyle: UIAlertControllerStyle.Alert)
        controller.addTextFieldWithConfigurationHandler(nil)
        controller.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            if let tf = controller.textFields?.last {
                if let number = Int(tf.text!){
                    self.addStopWithNumber(number)
                }
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func addStopWithNumber(number: Int){
        
        DBStopsManager.sharedInstance().stopWithNumber(number, handler: { (stop: DBBusStop?) -> Void in
            if let s = stop {
                if !s.favorite{
                    DBStopsManager.sharedInstance().setStop(s.stopNumber, asFavorite: true, handler: { (result: Bool) -> Void in
                        if (result){
                            self.stops.append(s);
                            self.tableView.reloadData();
                        }
                    })
                }
                
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        
        let stop = self.stops[indexPath.row]
        
        cell.textLabel?.text = stop.address
        cell.detailTextLabel?.text = "\(stop.stopNumber)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let toRemove = self.stops[indexPath.row]
            DBStopsManager.sharedInstance().setStop(toRemove.stopNumber, asFavorite: false, handler: { (result :Bool) -> Void in
                if (result){
                    self.stops.removeAtIndex(indexPath.row);
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            })
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let x = DBRealTimeTableViewController(stop: Int(self.stops[indexPath.row].stopNumber));
        self.navigationController?.pushViewController(x, animated: true);
    }
    
    /*
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let tmp = self.stops[sourceIndexPath.row]
        self.stops[sourceIndexPath.row] = self.stops[destinationIndexPath.row]
        self.stops[destinationIndexPath.row] = tmp
        StopsManager.sharedInstance.saveFavoritesBusStops(self.stops)
    }
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

}

