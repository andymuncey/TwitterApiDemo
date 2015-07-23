//
//  MasterViewController.swift
//  FindTweets
//
//  Created by Andrew Muncey on 23/07/2015.
//  Copyright (c) 2015 University of Chester. All rights reserved.
//

import UIKit

class TweetsViewController: UITableViewController {

    var tweets = Array<Dictionary<String,AnyObject>>()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let tweet = tweets[indexPath.row]
        cell.textLabel!.text = tweet["text"] as? String
        
        let user = tweet["user"] as! Dictionary<String,AnyObject>
        cell.detailTextLabel!.text = user["name"] as? String
        
        return cell
    }


}

