//
//  GlobalSplitViewController.swift
//  Calculator2
//
//  Created by Dane Osborne on 7/1/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit

//Without this class the split view controller shows detail view initially on iphone launch
class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    /*
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return true
    }
    */
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return true
    }
}
