//
//  BookmarkVC.swift
//  PregBuddy Tweets
//
//  Created by Tarun Jain on 05/03/18.
//  Copyright © 2018 PregBuddy. All rights reserved.
//

import UIKit
import CoreData

class BookmarkVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets = [tweetModel]()
    var Savedtweets = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Bookmarks"
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadTweets()
    }
    
    // MARK: Core data func
    
    func loadTweets(){
        // Load saved tweet entities from core data
        
        tweets.removeAll()
        Savedtweets.removeAll()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            for data in result as! [NSManagedObject] {
                
                let keys = Array(data.entity.attributesByName.keys)
                let dict = data.dictionaryWithValues(forKeys: keys)
                print(dict)
                self.tweets.append(tweetModel(dictionary: dict))
                self.Savedtweets.append(data)
                tableView.reloadData()
//                print(data)
//                print(data.value(forKey: "text") as! String)
            }
            
        } catch {
            
            print("Failed")
        }
    }

}

// MARK: - TableView Methods
extension BookmarkVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TweetCell
        
        cell.tweet.text = tweets[indexPath.row].tweet
//        cell.bookMarkBtn.tag = indexPath.row
        cell.bookMarkBtn.addTarget(self, action: #selector(self.bookmarkPressed(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func bookmarkPressed(sender: UIButton) {
        
        if let cell = sender.superview?.superview as? TweetCell{
            let indexPath = tableView.indexPath(for: cell)
        
    //        let index = sender.tag
            // Remove proper entity from core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(Savedtweets[indexPath!.row])
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
            
            // Remove cell from class array
            tweets.remove(at: indexPath!.row)
            
            // Removev cell from tableview
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        }
    }
}
