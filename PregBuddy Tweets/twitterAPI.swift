//
//  twitterAPI.swift
//  PregBuddy Tweets
//
//  Created by Tarun Jain on 05/03/18.
//  Copyright © 2018 PregBuddy. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class twitterAPI: NSObject {
    
    static let sharedInstance = twitterAPI()
    
    // Fetch Tweets
    public func fetchTweets(completion: @escaping ((Bool, [tweetModel], String?)->Void)) {
    
            let headers = ["Authorization":
                "Bearer AAAAAAAAAAAAAAAAAAAAALMU4wAAAAAAbtnxf6T3OoXjVuGUjm6JGKYv7ho%3DcH8g9gi0yoa87FWbDOnQMzKfYXkEY8DDvE8oATYqGSciEFUHWF"]
            let params: [String : Any] = [
                "q" : "pregnency",
                "result_type" : "recent",
                "count": 20
            ]
        
        Alamofire.request("https://api.twitter.com/1.1/search/tweets.json", method: .get, parameters: params, headers: headers).responseJSON(completionHandler: { (response) in
            
            switch response.result {
            case .success:
                let result = JSON(response.result.value!)
                print(result)
                if let tweetsArray = result["statuses"].arrayObject as? [[String:Any]] {
                    
                    var tweets = [tweetModel]()
            
                    for tweet in tweetsArray {
                        tweets.append(tweetModel(dictionary: tweet))
                    }
                    completion(true, tweets, nil)
                }
            case .failure(let error):
                print("error:",error.localizedDescription)
                completion(false, [], error.localizedDescription)
    
            }
        })
    }

}
