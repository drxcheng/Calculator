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
                display.text = " "
            } else {
                let intValue = Int(newValue!)
                let doubleValue = Double(intValue)
                display.text = newValue! == doubleValue ? "\(intValue)" : "\(newValue!)"
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
        if (displayValue == nil) {
            return
        }
        
        isTyping = false
        displayValue = brain.pushOperand(displayValue!)
        history.text = brain.desciption
    }
    
    @IBAction func clear()
    {
        display.text = " "
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
            displayValue = brain.performOperation(operation)
        }
        
        history.text = brain.desciption
    }
    
    @IBAction func saveMemory() {
        brain.saveMemory(displayValue)
        isTyping = false
        displayValue = brain.evaluate()
    }
    
    
    @IBAction func loadMemory() {
        enter()
        brain.loadMemory()
    }
}

