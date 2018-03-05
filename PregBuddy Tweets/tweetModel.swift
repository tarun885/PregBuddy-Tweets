//
//  tweetModel.swift
//  PregBuddy Tweets
//
//  Created by Tarun Jain on 05/03/18.
//  Copyright © 2018 PregBuddy. All rights reserved.
//

import Foundation
import UIKit

class tweetModel: NSObject {
    
    var tweet: String?
    var retweetCount: Int?
    var favoriteCount: Int?
    
    init(dictionary: [String: Any]) {
        super.init()
        
        tweet = dictionary["text"] as? String
        retweetCount = dictionary["retweet_count"] as? Int
        favoriteCount = dictionary["favorite_count"] as? Int
        
    }
}
