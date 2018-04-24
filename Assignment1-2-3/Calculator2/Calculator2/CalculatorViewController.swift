//
//  ViewController.swift
//  Calculator2
//
//  Created by Dane Osborne on 1/14/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    
    @IBOutlet weak private var display: UILabel!
    @IBOutlet weak var equation: UILabel!
    
    private var brain = CalculatorBrain()
    private var currentProgram: CalculatorBrain.PropertyList?
    private var userIsInTheMiddleOfTyping = false
    
    //Computed Property
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    /* Target / Action method called when user touches a digit in calculator view.
     *
     * @param - 
     */
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            if digit == "." && display.text!.range(of: ".") != nil {
                let textCurrentlyInDisplay = display!.text!
                display.text = textCurrentlyInDisplay
            } else {
                let textCurrentlyInDisplay = display!.text!
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction func assignVariable(_ sender: UIButton) {
        brain.variableValues["M"] = displayValue
        currentProgram = brain.program
        //currentProgram.variableValues["M"] = displayValue
        //print("M: \(String(describing: brain.variableValues["M"]))")
        if currentProgram != nil {
            brain.program = currentProgram!
            displayValue = brain.result
            print("M: \(String(describing: brain.variableValues["M"]))")
            userIsInTheMiddleOfTyping = false
        }
    }
    
    @IBAction func setPendingVariable(_ sender: UIButton) {
        brain.setOperand(operand: sender.currentTitle!)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping && !display!.text!.isEmpty {
            display!.text! = display!.text!.substring(to: display!.text!.index(before: display!.text!.endIndex))
        } else if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            
            
            //if decimal is extremely small round to 0
            //Ex) tan(π)
            if (round(brain.result * 1000) / 1000 == 0.0) {
                displayValue = 0.0
            } else {
                displayValue = brain.result
            }
            
            //append to end of equation
            if !brain.isPartialResult && display.text != "0.0" {
                equation.text = brain.getDescription + "="
            } else if display.text != "0.0" {
                equation.text = brain.getDescription + "..."
            } else {
                equation.text = ""
            }
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        //if decimal is extremely small round to 0
        //Ex) tan(π)
        if (round(brain.result * 1000) / 1000 == 0.0) {
            displayValue = 0.0
        } else {
            displayValue = brain.result
        }
        
        //append to end of equation
        if !brain.isPartialResult && display.text != "0.0" {
            equation.text = brain.getDescription + "="
        } else if display.text != "0.0" {
            equation.text = brain.getDescription + "..."
        } else {
           equation.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination
        if let graphVC = destinationVC.contentViewController as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "graph":
                    var z = 0
                    if !brain.isPartialResult {
                        graphVC.function = {
                            (x: CGFloat) -> Double in
                            print("run \(z)")
                            z += 1
                            self.brain.variableValues["M"] = Double(x)
                            self.brain.program = self.brain.program
                            return self.brain.result
                        }
                        var brainFunction = brain.getDescription
                        if brainFunction.range(of: "M") != nil {
                            brainFunction = brainFunction.replacingOccurrences(of: "M", with: "x")
                        }
                        
                        graphVC.navigationItem.title = "f(x) = " + brainFunction
                    }
                default:
                    break
                }
            }
        }
        /*
        if let destinationVC = segue.destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "graph":
                    destinationVC.function = {
                        (x: CGFloat) -> Double in
                        self.brain.variableValues["M"] = Double(x)
                        self.brain.program = self.brain.program
                        //print("result: \(self.brain.result)")
                        //print("Function")
                        return self.brain.result
                    }
                default:
                    break
                }
            }
        } */
    }
}
extension UIViewController {
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController!
        }
        else {
            return self
        }
    }
}

