//
//  HomeVC.swift
//  PregBuddy Tweets
//
//  Created by Tarun Jain on 05/03/18.
//  Copyright © 2018 PregBuddy. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    var tweets = [tweetModel]()
    var visibleTweets = [tweetModel]()
    var savedTweets = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "PregBuddy Tweets"
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadTweets), name: NSNotification.Name(rawValue: "loadTweets"), object: nil)
        
        self.loadTweets()
        
    }
    
    @objc func loadTweets() {
        
        segment.selectedSegmentIndex = 0
        self.visibleTweets.removeAll()
        self.tableView.reloadData()
        
        twitterAPI.sharedInstance.fetchTweets { (success, tweets, error) in
            if success {
                self.tweets = tweets
                
                if self.tweets.count > 20 {
                    self.visibleTweets = Array(tweets.prefix(20))
                }
                
                if self.segment.selectedSegmentIndex == 1 {
                    self.tweets.sort(by: {$0.favoriteCount! > $1.favoriteCount!})
                }else if self.segment.selectedSegmentIndex == 2 {
                    self.tweets.sort(by: {$0.retweetCount! > $1.retweetCount!})
                }else {
                    
                }
                
                // fetch saved tweets
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                request.returnsObjectsAsFaults = false
                
                var Tweets = [tweetModel]()
                do {
                    let result = try context.fetch(request)
                    for data in result as! [NSManagedObject] {
                        self.savedTweets.append(data)
                        print(self.savedTweets)
                        
                        let keys = Array(data.entity.attributesByName.keys)
                        let dict = data.dictionaryWithValues(forKeys: keys)
//                        print(dict)
                        Tweets.append(tweetModel(dictionary: dict))
                        
                    }
                    
                    for t in self.visibleTweets {
                        for T in Tweets{
                            if t.id == T.id {
                                t.isBookmarked = true
                            }
                        }
                    }
                    
//                    // set bookmark
//                    for i in 0..<tweets.count {
//                        if Tweets[safe: i]?.id! == tweets[i].id {
//                            tweets[i].isBookmarked = true
//                        }
//                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Failed")
                }
                
            }else{
                let alert = UIAlertController(title: "Error!", message: "\(error ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func loadMoreTweets() {
        
        print("visible", visibleTweets.count)
        print("total", tweets.count)
        
        for _ in 0..<20 {
            
            if visibleTweets.count < tweets.count{
                
                visibleTweets.append(tweets[visibleTweets.count])
                
            }
        }
        
        tableView.reloadData()
        
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            print(0)
            // fetch all tweets
            self.loadTweets()
        case 1:
            print(1)
            // fetch most liked tweets
            self.tweets.sort(by: {$0.favoriteCount! > $1.favoriteCount!})
            self.visibleTweets = self.tweets
            tableView.reloadData()
        case 2:
            print(2)
            // fetch most retweeted tweets
            self.tweets.sort(by: {$0.retweetCount! > $1.retweetCount!})
            self.visibleTweets = self.tweets
            tableView.reloadData()
        default:
            break;
        }
    }
    
}

// MARK: - TableView Methods
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch segment.selectedSegmentIndex {
        case 0:
            return visibleTweets.count
        case 1:
            return 10
        case 2:
            return 10
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TweetCell
        
        cell.tweet.text = visibleTweets[indexPath.row].tweet
        cell.likes.text = "Likes: \(visibleTweets[indexPath.row].favoriteCount ?? 0)"
        cell.retweets.text = "Retweets: \(visibleTweets[indexPath.row].retweetCount ?? 0)"
        cell.bookMarkBtn.tag = indexPath.row
        cell.bookMarkBtn.addTarget(self, action: #selector(self.bookmarkPressed), for: .touchUpInside)
        
        if tweets[indexPath.row].isBookmarked {
            cell.bookMarkBtn.setImage(#imageLiteral(resourceName: "bookmarked"), for: .normal)
        }else{
            cell.bookMarkBtn.setImage(#imageLiteral(resourceName: "bookmark"), for: .normal)
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.visibleTweets.count - 1 {
            if tweets.count > visibleTweets.count {
                loadMoreTweets()
            }
        }
    }
    
    @objc func bookmarkPressed(sender: UIButton) {
        print("bookmarked")
        let index = sender.tag
        
        if sender.currentImage == #imageLiteral(resourceName: "bookmark") {
            
                // Add tweet to core Data
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Tweet", in: context)
                let tweet = NSManagedObject(entity: entity!, insertInto: context)
                tweet.setValue(visibleTweets[index].tweet, forKey: "text")
                tweet.setValue(visibleTweets[index].retweetCount, forKey: "retweetCount")
                tweet.setValue(visibleTweets[index].favoriteCount, forKey: "favoriteCount")
                tweet.setValue(visibleTweets[index].id, forKey: "id")
            
                self.savedTweets.append(tweet)
            
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
                
                sender.setImage(#imageLiteral(resourceName: "bookmarked"), for: .normal)
            
                self.visibleTweets[index].isBookmarked = true
                tableView.reloadData()
            
        }else if sender.currentImage == #imageLiteral(resourceName: "bookmarked") {
            
            // Remove proper entity from core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            for savedtweet in savedTweets {
                if savedtweet.value(forKey: "id") as? Int == visibleTweets[index].id{
                    context.delete(savedtweet)
                }
            }
        
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
            
            sender.setImage(#imageLiteral(resourceName: "bookmark"), for: .normal)
            
            self.visibleTweets[index].isBookmarked = false
            tableView.reloadData()
        }
    }
}
