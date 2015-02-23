//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Xu Cheng on 2015-02-14.
//  Copyright (c) 2015 drxcheng. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knowOps = [String: Op]()
    
    var variableValues = Dictionary<String, Double>()
    
    private var lastOp = Op?()
    
    init()
    {
        func learnOp(op: Op) {
            knowOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("π", { M_PI * $0 }))
    }
    
    func clear()
    {
        opStack = [Op]()
        lastOp = nil
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double?
    {
        let (result, remainder) = evaluate(opStack)
        println("evaluate: \(opStack) = \(result) with \(remainder) left over")
        
        return result
    }
    
    func pushOperand(operand: Double) -> Double?
    {
        opStack.append(Op.Operand(operand))
        
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double?
    {
        var operand = variableValues[symbol]
        
        if operand == nil {
            return nil
        }
        
        opStack.append(Op.Operand(operand!))
        
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?
    {
        if let operation = knowOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    var desciption: String {
        get {
            return displayHistory()
        }
    }
    
    private func displayHistory() -> String
    {
        var result = "";
        var opsToShow = opStack

        do {
            let (partialResult, remainingOps, _) = displayHistory(opsToShow)
        
            result = result == "" ? "\(partialResult!)" : "\(partialResult!),\(result)"
            opsToShow = remainingOps
        } while (!opsToShow.isEmpty)

        return "\(result)="
    }
    
    private func displayHistory(ops: [Op]) -> (display: String?, remainingOps: [Op], isOperand: Bool)
    {
        if ops.isEmpty {
            return (nil, ops, true)
        }
        
        var remainingOps = ops
        let op = remainingOps.removeLast()
        
        switch op {
        case .Operand(let operand):
            let intValue = Int(operand)
            let doubleValue = Double(intValue)
            let operandDisplay = operand == doubleValue ? "\(intValue)" : "\(operand)"
            return (operandDisplay, remainingOps, true)
        case .UnaryOperation("π", _):
            return ("π", remainingOps, true)
        case .UnaryOperation(let symbol, _):
            let previousResult = displayHistory(remainingOps)
            let previousResultDisplay = previousResult.display == nil ? "?" : previousResult.display!
            return ("\(symbol)(\(previousResultDisplay))", previousResult.remainingOps, false)
        case .BinaryOperation(let symbol, _):
            let previousResult1 = displayHistory(remainingOps)
            let previousResult2 = displayHistory(previousResult1.remainingOps)
            let previousResult2Display = previousResult2.display == nil ? "?" : previousResult2.display!
            let previousResult1Display = needParentheses(op) && !previousResult1.isOperand ? "(\(previousResult1.display!))" : previousResult1.display!
            lastOp = op
            
            return ("\(previousResult2Display)\(symbol)\(previousResult1Display)", previousResult2.remainingOps, false)
        }
    }
    
    private func needParentheses(op: Op) -> Bool
    {
        if (lastOp == nil) {
            return false
        }
        
        if ((op.description == "×" || op.description == "÷") &&
            (lastOp!.description == "+" || lastOp!.description == "−")) {
            return true
        }
        
        return false
    }
}
