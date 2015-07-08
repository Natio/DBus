//
//  FavoritesInterfaceController.swift
//  DBus
//
//  Created by Paolo Coronati on 02/07/2015.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

import WatchKit
import ModelManager

class FavoritesInterfaceController: WKInterfaceController{
    
    var favoriteStops: [DBBusStop]?
    @IBOutlet weak var stopsList: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.fetchFavoritesStops()
    }

    func fetchFavoritesStops(){
        DBStopsManager.sharedInstance().favorites { (stops:[AnyObject]) -> Void in
            self.loadTableWithStops(stops as! [DBBusStop])
            return
        }

    }
    
    func loadTableWithStops(stops: [DBBusStop]){
        self.favoriteStops = stops
        self.stopsList.setNumberOfRows(stops.count, withRowType: "DBusWatchTableRow")
        for (var i = 0; i < stops.count; i++){
            let currentStop = stops[i]
            let row = self.stopsList.rowControllerAtIndex(i) as? DBusWatchTableRow
            row?.titleLabel.setText(currentStop.address)
            row?.distanceLabel.setText("")
            row?.numberLabel.setText("\(currentStop.stopNumber)")
        }
    }
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if let stops = self.favoriteStops{
            let selectedStop = stops[rowIndex]
            let ctx = ["address" : selectedStop.address, "stopNumber" : selectedStop.stopNumber]
            self.pushControllerWithName("RealTimeScene", context: ctx)
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