//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Dane Osborne on 9/9/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    //Private Implementation
    private func updateUI() {
        //tweetTextLabel?.text = tweet?.text
        //tweetUserLabel?.text = tweet?.user.description
         if let text = tweet?.text {
             let attributedText = setMentionColors(tweetText: text)
             tweetTextLabel.attributedText = attributedText
         }
         
         tweetUserLabel?.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            //put profile images on user initiated dispatch queue
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    self?.tweetProfileImageView?.image = UIImage(data: imageData)
                } else {
                    self?.tweetProfileImageView?.image = nil
                }
            }
            
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
    private func setMentionColors(tweetText: String) -> NSMutableAttributedString {
        let modifiedString = NSMutableAttributedString(string: tweetText)
        //loop through hashtags and apply color
        for hashtag in (tweet?.hashtags)! {
            modifiedString.addAttribute(NSForegroundColorAttributeName, value: MentionColors.hashtagColor, range: hashtag.nsrange)
        }
        //loop through urls and apply color
        for url in (tweet?.urls)! {
            modifiedString.addAttribute(NSForegroundColorAttributeName, value: MentionColors.urlColor, range: url.nsrange)
        }
        //loop through user mentions and apply color
        for userMention in (tweet?.userMentions)! {
            modifiedString.addAttribute(NSForegroundColorAttributeName, value: MentionColors.userScreenNameMentionColor, range: userMention.nsrange)
        }
        return modifiedString
    }
    
    //Color for text of tweets mentions (url's, hashtags, and screen names)
    private struct MentionColors {
        static let hashtagColor: UIColor = UIColor.blue
        static let urlColor: UIColor = UIColor.brown
        static let userScreenNameMentionColor: UIColor = UIColor.orange
    }
}
