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
    var selectedTweet: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "PregBuddy Tweets"
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        selectedTweet = NSMutableDictionary()
        
        twitterAPI.sharedInstance.fetchTweets { (success, tweets, error) in
            if success {
                self.tweets = tweets
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }else{
                let alert = UIAlertController(title: "Error!", message: "\(error ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch segment.selectedSegmentIndex
        {
        case 0:
            print(0)
            // fetch all tweets
            twitterAPI.sharedInstance.fetchTweets { (success, tweets, error) in
                if success {
                    self.tweets = tweets
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    let alert = UIAlertController(title: "Error!", message: "\(error ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        case 1:
            print(1)
            // fetch most liked tweets
            twitterAPI.sharedInstance.fetchTweets { (success, tweets, error) in
                if success {
                    self.tweets = tweets
                    self.tweets.sort(by: {$0.favoriteCount! > $1.favoriteCount!})
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    let alert = UIAlertController(title: "Error!", message: "\(error ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        case 2:
            print(2)
            // fetch most retweeted tweets
            twitterAPI.sharedInstance.fetchTweets { (success, tweets, error) in
                if success {
                    self.tweets = tweets
                    self.tweets.sort(by: {$0.retweetCount! > $1.retweetCount!})
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    let alert = UIAlertController(title: "Error!", message: "\(error ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
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
        
        if segment.selectedSegmentIndex == 0 {
            return tweets.count
        }else if segment.selectedSegmentIndex == 1 {
            return 10
        }else if segment.selectedSegmentIndex == 2 {
            return 10
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TweetCell
        
        cell.tweet.text = tweets[indexPath.row].tweet
        cell.bookMarkBtn.tag = indexPath.row
        cell.bookMarkBtn.addTarget(self, action: #selector(self.bookmarkPressed), for: .touchUpInside)
        
        if(selectedTweet?.object(forKey: indexPath.row) == nil){
            // Handle dynamic table loading to ensure checkmarks (or lack there of) are saved while user scrolls table
            cell.bookMarkBtn.setImage(#imageLiteral(resourceName: "bookmark"), for: .normal)
        }
        else{
            cell.bookMarkBtn.setImage(#imageLiteral(resourceName: "bookmarked"), for: .normal)
        }

        return cell
    }
    
    @objc func bookmarkPressed(sender: UIButton) {
        print("bookmarked")
        let index = sender.tag
        
        if sender.currentImage == #imageLiteral(resourceName: "bookmark") {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Tweet", in: context)
            let tweet = NSManagedObject(entity: entity!, insertInto: context)
            tweet.setValue(tweets[index].tweet, forKey: "text")
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
            
            sender.setImage(#imageLiteral(resourceName: "bookmarked"), for: .normal)
            
            if(selectedTweet?.object(forKey: index) != nil){
                // Tweet is already saved
            }
            else{
                // Add tweet to local data array
                selectedTweet?.setObject(tweets[index].tweet as String!, forKey: index as NSCopying)
            }
        }else if sender.currentImage == #imageLiteral(resourceName: "bookmarked") {
        
            sender.setImage(#imageLiteral(resourceName: "bookmark"), for: .normal)
            selectedTweet?.removeObject(forKey: index)
            
        }
    }
}
