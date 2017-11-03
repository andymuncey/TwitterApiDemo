import UIKit
import TwitterKit

class ViewController : UIViewController{
    
    //used to store the tweets once we have retrieved them
    var tweets = Array<Dictionary<String,AnyObject>>()
    
    @IBOutlet weak var searchTermTextField: UITextField!
    
    var loginButton : TWTRLogInButton?

    override func viewDidAppear(_ animated: Bool) {
        if Twitter.sharedInstance().sessionStore.session() == nil {
            loginButton = TWTRLogInButton { (session, error) in
                if (session != nil) {
                    print("logged in as \(session!.userName)")
                    
                }else {
                    print(error!.localizedDescription)
                }
            }
            
            loginButton!.center = view.center
            
            view.addSubview(loginButton!)
        } else {
                loginButton?.removeFromSuperview()
        }
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        if searchTermTextField.text?.characters.count == 0 {
            errorAlert(message: "Please enter a search term")
            return
        }
        
        
        if let twitterAccountId = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: twitterAccountId)
            
            //create a url pointing to appropriate part of the API
            let url = "https://api.twitter.com/1.1/search/tweets.json"
            
            //set the parameters for the API request (in this case q for a search)
            let params = ["q" : self.searchTermTextField!.text!]
            
            var clientError : NSError?
            
            //create a request
            let request = client.urlRequest(withMethod: "GET", url: url, parameters: params, error: &clientError)
            
            //make the request
            client.sendTwitterRequest(request) { (response, responseData, error) -> Void in
                
                //something has gone wrong with the request. probably should tell user
                if let err = error {
                    self.errorAlert(message: "Sorry, there seems to be a problem, please try again later")
                    print("\(err.localizedDescription)", terminator: "")
                    return
                }
                
                if responseData == nil {
                    //no response data - possible problem with twitter
                    self.errorAlert(message:"Sorry, Twitter does not seem to be responding at present")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300{
                        //http resonse error - log code
                        self.errorAlert(message:"Sorry, there seems to be a problem")
                        print("HTTP error: \(response!.description)")
                        return
                    }
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
            }
        }
    }
    
    func errorAlert(message: String){
        
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



