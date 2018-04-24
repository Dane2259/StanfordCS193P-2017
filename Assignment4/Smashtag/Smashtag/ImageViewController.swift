//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Dane Osborne on 9/10/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
// 

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    private var imageView: UIImageView = UIImageView()
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            self.scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.05
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
        
    }
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView.contentSize = imageView.frame.size
            //let rect = CGRect(x: 0, y: 0, width: imageView.bounds.width, height: scrollView.bounds.height / 2)
            //print("RectMaxY: \(rect.maxY)\nRectMaxX: \(rect.maxX)")
            //scrollView?.zoom(to: rect, animated: true)
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url as URL)
                if let imageData = urlContents, url == self?.imageURL {
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData as Data)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        // Do any additional setup after loading the view.
    }
}
