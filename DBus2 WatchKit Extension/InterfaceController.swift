//
//  InterfaceController.swift
//  DBus WatchKit Extension
//
//  Created by Paolo Coronati on 01/07/2015.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

import WatchKit
import Foundation
import ModelManager

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet weak var stopsList: WKInterfaceTable!
    
    var currentLocation: CLLocation?
    var oldLocation: CLLocation?
    let locationManager = CLLocationManager()
    var stops: [DBBusStop]?
    var updateTimer: NSTimer?
    let invocation_delay = 0.3
    var showFavorites = false
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways{
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.oldLocation = self.currentLocation
        self.currentLocation = (locations.last as? CLLocation?)!
        if self.oldLocation == nil{
            self.updateTimer?.invalidate()
            self.updateTimer = NSTimer(timeInterval: invocation_delay, target: self, selector: Selector("fetchData"), userInfo: nil, repeats: false)
            self.updateTimer?.fire()
            //fetchData()
        }
        else if let old = self.oldLocation, let new = self.currentLocation{
            self.updateTimer?.invalidate()
            self.updateTimer = NSTimer(timeInterval: invocation_delay, target: self, selector: Selector("fetchData"), userInfo: nil, repeats: false)
            self.updateTimer?.fire()
            /*
            let distance = old.distanceFromLocation(new)
            let diff = abs(old.timestamp.timeIntervalSinceDate(new.timestamp))
            
            if distance > 50 && diff < 20{
            fetchData()
            }
            else if diff > 60 {
            fetchData()
            }
            else{
            
            }
            */
            //fetchData()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        if let ctx = context as? [String: String]{
            if let _: AnyObject = ctx["favorites"]{
                showFavorites = true
            }
        }
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = Double(10.0)
        self.locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        //self.currentLocation = CLLocation(latitude:  53.350140, longitude: -6.266155)
        self.currentLocation = self.locationManager.location
        fetchData()
    }
    
    func fetchData(){
        if let current = self.currentLocation{
            
            let handler = { (stops: [AnyObject]) -> Void in
                self.loadTableData(stops as! [DBBusStop])
            }
            DBStopsManager.sharedInstance().stopsNearLocation(current, favorite: self.showFavorites, handler: handler);

        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if let stops = self.stops{
            if stops.count == 0 {return}
            let selectedStop = stops[rowIndex]
            let ctx = ["address" : selectedStop.address, "stopNumber" : selectedStop.stopNumber]
            self.pushControllerWithName("RealTimeScene", context: ctx)
        }
    }
    
    
    func loadTableData(stops: [DBBusStop]){
        
        if currentLocation == nil{
            return
        }
        self.stops = stops
        if stops.count == 0{
            self.stopsList.setNumberOfRows(1, withRowType: "DBusWatchTableRow")
            let row = self.stopsList.rowControllerAtIndex(0) as? DBusWatchTableRow
            row?.titleLabel.setText("No stops found around you")
            row?.distanceLabel.setText("")
            row?.numberLabel.setText("")
        }
        else{
            
            self.stopsList.setNumberOfRows(stops.count, withRowType: "DBusWatchTableRow")
            
            for (var i = 0; i < stops.count; i++){
                let currentStop = stops[i]
                let location = CLLocation(latitude: currentStop.coordinate.latitude, longitude: currentStop.coordinate.longitude)
                let distanceInMeters = location.distanceFromLocation(self.currentLocation!)
                let distanceString = String(format: "%.0fm", arguments: [distanceInMeters])
                
                let row = self.stopsList.rowControllerAtIndex(i) as? DBusWatchTableRow
                row?.titleLabel.setText(currentStop.address)
                row?.distanceLabel.setText(distanceString)
                row?.numberLabel.setText("\(currentStop.stopNumber)")

            }
        }
        
    
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
