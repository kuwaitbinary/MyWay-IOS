//
//  commentMajorAccident.swift
//  viewreports
//
//  Created by trn15 on 8/13/15.
//  Copyright (c) 2015 PIFSS. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class commentMajorAccident:UITableViewController{
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var manager:addAccidentsReport = addAccidentsReport();
        return manager.showAllReports().count;
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var row:Int = indexPath.row;
        var manager:addAccidentsReport = addAccidentsReport();
        var list:NSMutableArray = manager.showAllReports();
        
        var cell:UITableViewCell = UITableViewCell();
        var values:NSDictionary = list.objectAtIndex(row) as! NSDictionary;
        cell.textLabel?.text = values.objectForKey("comment") as! String;
        cell.textLabel?.numberOfLines = 5;
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row:Int = indexPath.row;
        var manager:addAccidentsReport = addAccidentsReport();
        var list:NSMutableArray = manager.showAllReports();
        var values:NSDictionary = list.objectAtIndex(row) as! NSDictionary;
        var report:CommentLocation = CommentLocation().objectFromDict(values);
        
        var showMap:ShowOnMapVC = UIStoryboard(name: "reqLocaiton", bundle: nil).instantiateViewControllerWithIdentifier("ShowOnMapVC") as! ShowOnMapVC;
        showMap.title = "Major Accedint";
        showMap.message = report.comment;
        showMap.location = report.reportLocation;
        
//        let (latitud, longitud) =  GetLocationVC().getCurrentLocation()

//        var myCLL:CLLocation = CLLocation(latitude:(report.values.objectForKey("lat")as! NSString).doubleValue, longitude:(report.values.objectForKey("lon")as! NSString).doubleValue);
//        showMap.location = myCLL
        self.navigationController?.pushViewController(showMap, animated: true);

    }

    
}