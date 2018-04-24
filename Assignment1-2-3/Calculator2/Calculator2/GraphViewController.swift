//
//  GraphViewController.swift
//  Calculator2
//
//  Created by Dane Osborne on 7/2/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var graphView: GraphView! {
        
        didSet {
            graphView.data = self
            
            let recognizer = UIPanGestureRecognizer(
                target: graphView, action: #selector(GraphView.pan(gesture:))
            )
            graphView.addGestureRecognizer(recognizer)
            
            let zoomRecognizer = UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.zoom(gesture:))
            )
            graphView.addGestureRecognizer(zoomRecognizer)
            
            let tapRecognizer = UITapGestureRecognizer(
                target: graphView, action: #selector(GraphView.tap(gesture:))
            )
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
        }
 
    }
    
    func getBounds() -> CGRect {
        return view.bounds
    }
    
    var function: ((CGFloat) -> Double)?
    
    func getYCoordinate(x: CGFloat) -> CGFloat? {
        if function != nil {
            return CGFloat(function!(x))
        }
        return nil
        //return CGFloat(x)
    }
}
