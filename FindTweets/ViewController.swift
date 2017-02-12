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
    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        if searchTermTextField.text?.characters.count == 0 {
            self.errorAlertWithMessage("Please enter a search term")
            return
        }
        
        //access the account store
        let accountStore = ACAccountStore()
        
        //variable for the appropriate type of account
        let twitterAccountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        //request access to the account (iOS will prompt the user)
        accountStore.requestAccessToAccounts(with: twitterAccountType, options: nil, completion: { (success, error) -> Void in
            
            if (!success) {
                //not granted access due to privacy settings
                self.errorAlertWithMessage("You have denied this app access to Twitter, please enable access in Settings -> Privacy")
                return
            }

            //get all the twitter accounts
            let accounts = accountStore.accounts(with: twitterAccountType)
            
            if accounts?.count == 0 {
                //no twitter accounts set up
                self.errorAlertWithMessage("There are no Twitter accounts setup on this device")
                return
            }
            
            //create a url pointing to the API
            let url : URL = URL(string: "https://api.twitter.com/1.1/search/tweets.json")!
            
            //set the parameters for the API request (in this case q for a search)
            let parameters = ["q" : self.searchTermTextField!.text!]
            
            //create a request
            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, url: url, parameters: parameters)
            //set the account for the request
            request?.account = accounts?.last as! ACAccount

            //make the request
            request?.perform(handler: { (responseData, urlResponse, error) -> Void in
            
                //something has gone wrong with the request. probably should tell user
                if let err = error {
                    self.errorAlertWithMessage("Sorry, there seems to be a problem, please try again later")
                    print("\(err.localizedDescription)", terminator: "")
                    return
                }
                
                if responseData == nil {
                    //no response data - possible problem with twitter
                    self.errorAlertWithMessage("Sorry, Twitter does not seem to be responding at present")
                    return
                }
                
                if urlResponse!.statusCode < 200 || urlResponse!.statusCode >= 300{
                    //http resonse error - log code
                    self.errorAlertWithMessage("Sorry, there seems to be a problem")
                    print("HTTP error: \(urlResponse!.description)")
                    return
                }
                
                //deserialise the data
                let jsonData : Any
                do {
                    jsonData = try JSONSerialization.jsonObject(with: responseData!, options: JSONSerialization.ReadingOptions.allowFragments)
                } catch  {
                    fatalError()
                }
                
                //the API tells us that the data will be a dictionary, where the keys are strings
                if let result = jsonData as? Dictionary<String,AnyObject>{
                    
                    //the API also tells us that the tweets will be an array in the dictionary
                    //with the key 'statuses'
                    if let statuses = result["statuses"] as? Array<Dictionary<String,AnyObject>> {
                        self.tweets = statuses
                    }
                    //self.tweets = result["statuses"] as? Array<Dictionary<String,AnyObject>>
                    
                    //go back to the main thread and perform a segue to view results
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "tweetsTable", sender: self)
                    }
                }
            })
        })
    }
    
    func errorAlertWithMessage(_ message: String){
        
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
        DispatchQueue.main.async(execute: {
                self.present(errorAlert, animated: true, completion: nil)
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let table = segue.destination as! TweetsViewController
        
        //pass the data to the table view controller so it can display tweets
        table.tweets = self.tweets
        table.title = self.searchTermTextField.text
    }
}
