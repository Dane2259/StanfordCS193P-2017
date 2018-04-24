//
//  MentionTableViewController.swift
//  Smashtag
//
//  Created by Dane Osborne on 9/9/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit
import Twitter

class MentionTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet!
    private var tweetMentions = Array<Data>()
    
    private enum Data {
        case UserMentions([Mention])
        case Hashtags([Mention])
        case Url([Mention])
        case Images([MediaItem])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSections()
        //tableView.estimatedRowHeight = tableView.rowHeight
        //tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }

    // MARK: - MentionTableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweetMentions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tweetMentions[section] {
        case .Images( _):
            return "Images"
        case .Url( _):
            return "Urls"
        case .UserMentions( _):
            return "User Mentions"
        case .Hashtags( _):
            return "Hashtags"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tweetMentions[section] {
        case .Images(let media):
            
            return media.count
        case .Url(let url):
            return url.count
        case .UserMentions(let mentions):
            return mentions.count
        case .Hashtags(let hashtags):
            return hashtags.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tweetMentions[indexPath.section] {
        case .Images(let images):
            let mediaItem = images[indexPath.row]
            let height = view.bounds.width / CGFloat(mediaItem.aspectRatio)
            return height
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tweetMentions[indexPath.section] {
        case .Url(let urls):
            let mention = urls[indexPath.row]
            let url = NSURL(string: mention.keyword)
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        switch tweetMentions[indexPath.section] {
        case .UserMentions(let mentions):
            cell = tableView.dequeueReusableCell(withIdentifier: "Mentions")!
            cell.textLabel?.text = mentions[indexPath.row].keyword
            return cell
        case .Hashtags(let hashtags):
            cell = tableView.dequeueReusableCell(withIdentifier: "Mentions")!
            cell.textLabel?.text = hashtags[indexPath.row].keyword
            return cell
        case .Url(let urls):
            cell = tableView.dequeueReusableCell(withIdentifier: "Urls")!
            cell.textLabel?.text = urls[indexPath.row].keyword
            return cell
        case .Images(let images):
            var cell = ImageTableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: "Images")! as! ImageTableViewCell
            cell.media = images[indexPath.row]
            //print("imageHeight: \(images)\nCellForRowAt: \(view.bounds.width)")
            let imageHeight = view.bounds.height / CGFloat((cell.media?.aspectRatio)!) 
            cell.frame = CGRect(x: 0,y: 0, width: cell.bounds.width, height: imageHeight)
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let cell = sender as? ImageTableViewCell {
            if segue.identifier == "ImageSegue" {
                if let destination = segue.destination as? ImageViewController {
                    let urlText = String(describing: (cell.media?.url)!)
                    destination.imageURL = NSURL(string: urlText)
                }
            }
        } else if let cell = sender as? UITableViewCell {
            if segue.identifier == "MentionSearch" {
                if let destination = segue.destination as? TweetTableViewController {
                    destination.searchText = cell.textLabel?.text
                }
            }
        }
    }
    
    private func loadSections() {
        var arrayIndex = 0
        
        if (tweet?.media.count)! > 0 {
            let tweetImages = Data.Images((tweet?.media)!)
            tweetMentions.insert(tweetImages, at: arrayIndex)
            arrayIndex += 1
        }
        
        if (tweet?.userMentions.count)! > 0 {
            let tweetUserMentions = Data.UserMentions((tweet?.userMentions)!)
            tweetMentions.insert(tweetUserMentions, at: arrayIndex)
            arrayIndex += 1
        }
        
        if (tweet?.hashtags.count)! > 0 {
            let tweetHashtags = Data.Hashtags((tweet?.hashtags)!)
            tweetMentions.insert(tweetHashtags, at: arrayIndex)
            arrayIndex += 1
        }
        
        if (tweet?.urls.count)! > 0 {
            let tweetUrls = Data.Url((tweet?.urls)!)
            tweetMentions.insert(tweetUrls, at: arrayIndex)
            arrayIndex += 1
        }
    }
}
