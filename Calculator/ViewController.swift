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

    var brain = CalculatorBrain()
    
    var displayValue: Double?
    {
        get {
            var number = NSNumberFormatter().numberFromString(display.text!);
            return number == nil ? nil : number!.doubleValue
        }
        set {
            if newValue == nil {
                display.text = "0"
            } else {
                display.text = "\(newValue!)"
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton)
    {
        let digit = sender.currentTitle!
        
        if isTyping && display.text != "0" {
            display.text = display.text! + digit
        } else {
            display.text = digit
            isTyping = true
        }
    }

    @IBAction func addDot()
    {
        let isInteger = displayValue! % 1 == 0
        
        if isInteger {
            display.text = display.text! + "."
        } else if !isTyping {
            display.text = "0."
        }
        isTyping = true
    }
    
    @IBAction func enter()
    {
        isTyping = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = 0
        }
        
        brain.addHistory(display.text!)
        history.text = brain.getHistory()
    }
    
    @IBAction func clear()
    {
        display.text = "0"
        history.text = ""
        isTyping = false
        brain.clear()
    }
    
    @IBAction func backspace()
    {
        var displayTextLength = countElements(display.text!)
        
        if displayTextLength > 1 && display.text! != "0" {
            display.text = dropLast(display.text!)
        } else {
            display.text = "0"
        }
    }
    
    @IBAction func sign()
    {
        displayValue = 0 - displayValue!
    }
    
    @IBAction func operate(sender: UIButton)
    {
        if isTyping {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
}

