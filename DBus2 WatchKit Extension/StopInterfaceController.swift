//
//  StopInterfaceController.swift
//  DBus
//
//  Created by Paolo Coronati on 02/07/2015.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

import WatchKit

class StopInterfaceController: WKInterfaceController{
    
    @IBOutlet weak var busList: WKInterfaceTable!
    @IBOutlet weak var stopNameLabel: WKInterfaceLabel!
    @IBOutlet weak var stopNumberLabel: WKInterfaceLabel!
    @IBOutlet weak var stopRoutesLabel: WKInterfaceLabel!
    var stopNumber: Int?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.stopRoutesLabel.setText(nil)
        if let ctx = context as? NSDictionary{
            self.stopNumber = ctx["stopNumber"] as? Int
            self.stopNumberLabel.setText("\(self.stopNumber!)")
            self.stopNameLabel.setText(ctx["address"] as? String)
        }
        
    }
    
    func fetchRealTimeInfoForStopNumber(number: Int){
        DBStopsManager.sharedInstance().getRealTimeDataForStop(number, handler: {
            (stop: DBRealTimeStop?) -> Void in
            self.updateTableViewWithRealTimeBusStop(stop)
            return
        })
    }
    
    func updateTableViewWithRealTimeBusStop(rtbs: DBRealTimeStop?){
        if let stop = rtbs{
            
            self.busList.setNumberOfRows(stop.buses.count, withRowType: "realtime")
           
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            
            for (var i = 0; i < stop.buses.count; i++){
                let currentBus = stop.buses[i] as? DBRealTimeStopTime
                let row = self.busList.rowControllerAtIndex(i) as? RealTimeBusInfoRow
                row?.routeNameLabel.setText(currentBus?.route)
                row?.etaLabel.setText(dateFormatter.stringFromDate(currentBus!.eta))
            }
        } else {
            
            
        }
    }
    
    @IBAction func makeCurrentFav(){
        DBStopsManager.sharedInstance().setStop(self.stopNumber!, asFavorite: true) { (result: Bool) -> Void in}
    
    }
    
    @IBAction func removeCurrentFromFavs(){
        
        DBStopsManager.sharedInstance().setStop(self.stopNumber!, asFavorite: true) { (result: Bool) -> Void in}
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.fetchRealTimeInfoForStopNumber(self.stopNumber!)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
