//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Dane Osborne on 9/10/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit
import Twitter

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetImage: UIImageView!
    var media: Twitter.MediaItem? { didSet { updateUI() } }
    
    private func updateUI() {
        //print("AspectRatio\(String(describing: media?.aspectRatio))\nDeviceWidth: \(UIScreen.main.bounds.width).bounds.height)")
        tweetImage.frame = CGRect(x: 0, y: 0,
                                  width: Int(UIScreen.main.bounds.width),
                                  height: Int(UIScreen.main.bounds.width / CGFloat((media?.aspectRatio)!)))
        tweetImage.contentMode = UIViewContentMode.scaleToFill
        DispatchQueue.global(qos: .userInitiated).async {
            let urlContents = try? Data(contentsOf: (self.media?.url)! as URL)
            DispatchQueue.main.async {
                self.tweetImage.image = UIImage(data: urlContents!)
            }
        }
    }
}
