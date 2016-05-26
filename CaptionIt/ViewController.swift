//
//  ViewController.swift
//  CaptionIt
//
//  Created by 17ocho on 4/18/16.
//  Copyright © 2016 Christine Cho. All rights reserved.

/* bugs to fix
* 1. When keyword is not in database
* 2. When user searches for different keywords
*/

import UIKit

class ViewController: UITableViewController
{
    var captions: [NSString] = []
   
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Getting values in api with keyword
    @IBAction func getValue(sender: AnyObject) {
        let userNameValue = userNameTextField.text
        
        if isStringEmpty(userNameValue!) == true {
            return
        }
        
        // Send HTTP GET Request
        let searchWord = userNameValue!
        //need to get my own key
        let tomatoesURL = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=56vedqj7hdewt45xt8kr485h&q=\(searchWord)&page_limit=30"
        //let tomatoesURL = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/current_releases.json?q=dog&apikey=56vedqj7hdewt45xt8kr485h"
        //print(tomatoesURL)
        //let urlWithParams = scriptUrl + "?userName=\(userNameValue!)"
        //let myUrl = NSURL(string: urlWithParams)
        let myUrl = NSURL(string: tomatoesURL)
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "GET"
        
        // Add Basic Authorization
        /*
        let username = "myUserName"
        let password = "myPassword"
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")
        */
        
        // Or add Token value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
            
            // Convert server json response to NSDictionary
            do {
                //self.captions = []
                self.captions.removeAll()
                self.tableView.reloadData()
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    // Rotten Tomatoes parsing part
                    if let movieArray = convertedJsonIntoDict["movies"] as? NSArray {
                        for movieDataContainer in movieArray {
                            if let movieData = movieDataContainer as? NSDictionary {                                
                                //adding movies with keyword to captions array
                                self.captions.append((movieData["title"] as? NSString)!)
                                let indexPath = NSIndexPath(forRow: self.captions.count-1, inSection: 0)
                                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            } else {
                                print("Error getting movie information")
                            }
                        }
                    }
                    print(self.captions)
                    //clear captions array so when user searches again, it won't display movies based on past keywords
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }
    
    
    func isStringEmpty(var stringValue:String) -> Bool
    {
        var returnValue = false
        
        if stringValue.isEmpty  == true
        {
            returnValue = true
            return returnValue
        }
        
        stringValue = stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(stringValue.isEmpty == true)
        {
            returnValue = true
            return returnValue
            
        }
        
        return returnValue
        
    }
    
    //Tableview Functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.captions.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CaptionCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.captions[indexPath.row] as String
        return cell
    }

}
