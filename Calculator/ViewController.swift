//
//  ViewController.swift
//  Calculator
//
//  Created by Xu Cheng on 2015-01-30.
//  Copyright (c) 2015 drxcheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var isTyping = false
    var isOperation = false
    var operandStack = Array<Double>()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if (isTyping && display.text != "0") {
            display.text = display.text! + digit
        } else {
            display.text = digit
            isTyping = true
        }
    }

    @IBAction func addDot() {
        let isInteger = displayValue % 1 == 0
        
        if (isInteger) {
            display.text = display.text! + "."
        } else if (!isTyping) {
            display.text = "0."
            isTyping = true
        }
    }
    
    @IBAction func enter() {
        if (!isOperation) {
            if (history.text?.isEmpty == true) {
                history.text = display.text!
            } else {
                history.text = history.text! + "," + display.text!
            }
        }
        isTyping = false
        operandStack.append(displayValue)
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue;
        }
        set {
            display.text = "\(newValue)";
            isTyping = false;
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if isTyping {
            enter()
        }
        isOperation = true
        switch operation {
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "π": performOperation { M_PI * $0 }
        case "√": performOperation { sqrt($0) }
        default: break
        }
        history.text = history.text! + "," + operation
        isOperation = false
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    @IBAction func clear() {
        display.text = "0"
        history.text = ""
        isTyping = false
        isOperation = false
        operandStack = Array<Double>()
    }
    
    @IBAction func backspace() {
        var displayTextLength = countElements(display.text!)
        
        if (displayTextLength > 1 && display.text! != "0") {
            display.text = dropLast(display.text!)
        } else {
            display.text = "0"
        }
    }
}

