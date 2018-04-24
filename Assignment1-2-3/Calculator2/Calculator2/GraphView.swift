//
//  GraphView.swift
//  Calculator2
//
//  Created by Dane Osborne on 7/1/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit

// https://www.natashatherobot.com/ios-weak-delegates-swift/
protocol GraphViewDataSource: class {
    func getBounds() -> CGRect
    func getYCoordinate(x: CGFloat) -> CGFloat?
}

class GraphView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    var scale: CGFloat = 1 { didSet { setNeedsDisplay() } }
    var origin: CGPoint! { didSet{ setNeedsDisplay() } }
    weak var data: GraphViewDataSource!
    
    override func draw(_ rect: CGRect) {
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        let axesDrawer = AxesDrawer(color: UIColor.blue, contentScaleFactor: CGFloat(1))
        axesDrawer.drawAxesInRect(self.bounds, origin: origin, pointsPerUnit: scale)
        
        getPath().stroke()
        
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed, .ended:
            let translation = gesture.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            //print("origin x: \(origin.x)\norigin.y: \(origin.y)")
            gesture.setTranslation(CGPoint.zero, in: self)
            
        default: break
        }
    }
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed, .ended:
            self.scale *= gesture.scale
            //print("Gesture.scale = \(gesture.scale)")
            gesture.scale = 1.0
        default:
            break
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            origin = gesture.location(in: self)
        default:
            break
        }
    }
 
    private func getPath() -> UIBezierPath {
        let path = UIBezierPath()
        var point = CGPoint()
        var firstPointNotSet = true
        
        let width = Int(self.bounds.width * scale)
        print("width: \(width)")
        for pixel in 0...width {
            point.x = (CGFloat(pixel)) / scale
            if let y = data.getYCoordinate(x: (point.x - origin.x) / scale) {
                //print("y: \(y)")
                if !y.isNormal {
                    firstPointNotSet = true
                    continue
                    
                }
                point.y = origin.y - y * scale
                if firstPointNotSet {
                    path.move(to: point)
                    //print("First point: (\(point.x), \(point.y))")
                    firstPointNotSet = false
                } else {
                    path.addLine(to: point)
                    //print("New point: (\(point.x), \(point.y))")
                }
                
            }
        }
        return path
    }
}
