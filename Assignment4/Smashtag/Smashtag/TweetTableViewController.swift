//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Dane Osborne on 9/9/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit
import Twitter

var tweetTableViewInstance = 0

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    private var tweets = [Array<Twitter.Tweet>]() //{ didSet { print(tweets) } }
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
            //Store latest 100 searches
            if !TweetTableViewController.lastHundredTwitterSearches.contains(where: { $0 == searchText?.lowercased() }) {
                TweetTableViewController.lastHundredTwitterSearches.insert(searchText?.lowercased(), at: 0)
                TweetTableViewController.lastHundredTwitterSearches.removeLast()
            }
            //print("\(TweetTableViewController.lastHundredTwitterSearches)\n\(TweetTableViewController.lastHundredTwitterSearches.count)")
        }
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    public static var lastHundredTwitterSearches: [String?] = [String?](repeating: nil, count: 100)
    
    private func searchForTweets() {
        if let request = twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        self?.tweets.insert(newTweets, at:0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                }
            }
        }
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //tweetTableViewInstance += 1
        //print("ViewDidLoad\ninstanceCount: \(tweetTableViewInstance)")
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    /*
    deinit {
        tweetTableViewInstance -= 1
        print("Deinit\ninstanceCount: \(tweetTableViewInstance)")
    } */
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        // Configure the cell...
        let tweet = tweets[indexPath.section][indexPath.row]
        //cell.textLabel?.text = tweet.text
        //cell.detailTextLabel?.text = tweet.user.name
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view contoller using segue.destinationViewController
        // Pass the selected object to the new view controller
        if let cell = sender as? TweetTableViewCell {
            if let destination = segue.destination as? MentionTableViewController {
                destination.tweet = cell.tweet
            }
        }
    }
}
