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
    
    var tweets = Array<Dictionary<String,AnyObject>>()
    
    @IBOutlet weak var searchTermTextField: UITextField!
    
    @IBAction func searchPressed(sender: UIButton) {
        
        
        sender.addSubview(UIActivityIndicatorView())
        
        var accountStore = ACAccountStore()
        
        var twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil, completion: { (success: Bool, error:NSError!) -> Void in
            
            if success {
                
                var accounts = accountStore.accountsWithAccountType(twitterAccountType)
                
                //assuming there is an account (a better approach would be to ask the user which one if multiple accounts)
                if accounts.count > 0{
                    
                    
                    var url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
                    
                    let parameters = ["q" : self.searchTermTextField.text]
                    
                    var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: parameters)
                    
                    request.account = accounts.last as! ACAccount
                    
                    request.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                        
                        if responseData != nil{
                            
                            if urlResponse.statusCode >= 200 && urlResponse.statusCode < 300{
                                //got an 'OK' response
                                
                                var jsonError = NSErrorPointer()
                                
                                let jsonData : AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments, error: jsonError)
                                
                                if let result = jsonData as? Dictionary<String,AnyObject>{
                                    
                                    self.tweets = result["statuses"] as! Array<Dictionary<String,AnyObject>>
                                    
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.performSegueWithIdentifier("tweetsTable", sender: self)
                                        }
                                }
                                
                                
                            }
                            
                        }
                        
                        
                        if let err = error {
                            print("\(err.localizedDescription)")
                        }
                        
                        
                        
                    })
                    
                }
            }
            
            
        })

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var table = segue.destinationViewController as! TweetsViewController
        
        table.tweets = self.tweets
        table.title = self.searchTermTextField.text
        
    }
    
}
