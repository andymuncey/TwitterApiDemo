//
//  ViewController.swift
//  
//
//  Created by Andrew Muncey on 23/07/2015.
//
//

import UIKit
import Social
import Accounts

class ViewController : UIViewController{
    
    //used to store the tweets once we have retrieved them
    var tweets = Array<Dictionary<String,AnyObject>>()
    
    @IBOutlet weak var searchTermTextField: UITextField!
    
    @IBAction func searchPressed(sender: UIButton) {
        
        //access the account store
        let accountStore = ACAccountStore()
        
        //variable for the appropriate type of account
        let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        //request access to the account (iOS will prompt the user)
        accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil, completion: { (success: Bool, error:NSError!) -> Void in

            if (!success) {
                //not granted access - probably should tell the user that the app wont work without access
                //and how they can grant access in settings
                print("Access to twitter accounts denied by user")
                return
            }

            //get all the twitter accounts
            let accounts = accountStore.accountsWithAccountType(twitterAccountType)

            if accounts.count == 0 {
                //no twitter accounts set up - probably should tell the user
                print("No accounts configured on the device")
                return
            }

            //create a url pointing to the API
            let url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")

            //set the parameters for the API request (in this case q for a search)
            let parameters = ["q" : self.searchTermTextField.text as String!]
                    
            //create a request
            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: parameters)
            //set the account for the request
            request.account = accounts.last as! ACAccount

            //make the request
            request.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                        
                //something has gone wrong with the request. probably should tell user
                if let err = error {
                    print("\(err.localizedDescription)", terminator: "")
                    return
                }

                if responseData == nil {
                    //no response data - possible problem with twitter
                    print("No response data")
                    return
                }

                if urlResponse.statusCode < 200 || urlResponse.statusCode >= 300{
                    //http resonse error - log code
                    print("HTTP error: \(urlResponse.description)")
                    return
                }

                //deserialise the data
                let jsonError = NSErrorPointer()
                let jsonData : AnyObject?
                do {
                    jsonData = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments)
                } catch let error as NSError {
                    jsonError.memory = error
                    jsonData = nil
                } catch {
                    fatalError()
                }
                                
                //the API tells us that the data will be a dictionary, where the keys are strings
                if let result = jsonData as? Dictionary<String,AnyObject>{
                                    
                    //the API also tells us that the tweets will be an array in the dictionary
                    //with the key 'statuses'
                    self.tweets = result["statuses"] as! Array<Dictionary<String,AnyObject>>

                    //go back to the main thread and perform a segue to view results
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("tweetsTable", sender: self)
                    }
                }
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let table = segue.destinationViewController as! TweetsViewController
    
        //pass the data to the table view controller so it can display tweets
        table.tweets = self.tweets
        table.title = self.searchTermTextField.text
    }
}
