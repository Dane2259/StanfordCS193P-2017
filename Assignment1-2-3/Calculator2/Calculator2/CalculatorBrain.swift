//
//  CalculatorBrain.swift
//  Calculator2
//
//  Created by Dane Osborne on 1/16/17.
//  Copyright © 2017 Dane Osborne. All rights reserved.
//

import Foundation

class CalculatorBrain {
    // private instance variables
    private var accumulator = 0.0
    private var pending: PendingBinaryOperationInfo?
    private var description = ""
    private var internalProgram = [AnyObject]()
    private var setDescription = true
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "✕" : Operation.BinaryOperation({ $0 * $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "log" : Operation.UnaryOperation(log10),
        "ln"  : Operation.UnaryOperation(log),
        "±" : Operation.UnaryOperation({ -$0 }),
        "x^2" : Operation.UnaryOperation({ pow($0, 2) }),
        "x^3" : Operation.UnaryOperation({ pow($0, 3) }),
        "=" : Operation.Equals,
        "c" : Operation.Clear,
        "↵" : Operation.Undo
        //"➝M" : Operation.AssignVariable
    ]
    
    // enumerated data-types copy on assignment (Value Types)
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
        case Undo
    }
    
    // structs copy on assignment (Value Types)
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    // private functions
    private func executePendingBinaryOperation() {
        if (pending != nil) {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }

    private func clear() {
        accumulator = 0.0
        pending = nil
        description = ""
        internalProgram.removeAll()
        //variableValues["M"] = nil
    }
    
    private func addParentheses(operation: String) {
        if isPartialResult {
            let operandToRemove = description.range(of: String(accumulator), options: .backwards)
            description = description.substring(to: (operandToRemove?.lowerBound)!)
                         + operation + "(" + String(accumulator) + ")"
        } else {
            description = operation + "(" + description + ")"
        }
    }
    
    //read-only computed property
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var getDescription: String {
        get {
            return description
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var variableValues: Dictionary<String, Double> = Dictionary()
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        } set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                var temp: Double?
                for op in arrayOfOps {
                    if let operation = op as? String {
                        if operations[operation] != nil {
                            performOperation(symbol: operation)
                            //print("\(operation)")
                        } else if variableValues[operation] != nil {
                            temp = variableValues[operation]
                            setOperand(operand: operation)
                            
                            //print("\(String(describing: temp))")
                        } else {
                            setOperand(operand: operation)
                            //print("\(operation)")
                        }
                    }
                    if let operand = op as? Double {
                        //print("\(operand)")
                        setOperand(operand: operand)
                    } else if temp != nil {
                        setDescription = false
                        setOperand(operand: temp!)
                        temp = nil
                        //print("\(String(describing: temp))")
                    }
                }
                setDescription = true
            }
        }
    }
    
    // public methods
    func setOperand(operand: Double) {
        accumulator = operand
        if setDescription {
            //if !isPartialResult {
            //    description = ""
            //}
            description += String(operand)
            internalProgram.append(operand as AnyObject)
        }
        setDescription = true
    }
    
    func setOperand(operand: String) {
        accumulator = 0.0
        //if !isPartialResult && setDescription {
        //    description = ""
        //}
        if setDescription {
            description += operand
            internalProgram.append(operand as AnyObject)
        }
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                description += symbol
            case .UnaryOperation(let function):
                addParentheses(operation: symbol)
                accumulator = function(accumulator)
                //print("Unary Operation: \(description)")
            case .BinaryOperation(let function):
                //print("\(description)")
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                description += symbol
                //print("Binary Operation: \(description)")
            case .Equals:
                executePendingBinaryOperation()
                //print("Equals Operation: \(description)")
            case .Clear:
                clear()
            case .Undo:
                internalProgram.removeLast()
                if internalProgram.count > 0 {
                    internalProgram.removeLast()
                }
                program = internalProgram as CalculatorBrain.PropertyList
            }
        }
    }
}
