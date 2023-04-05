//
//  Stack.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 05/05/22.
//

import Foundation
public struct Stack<T>
{
    private var items: [T] = []
    public func peek() -> T {
            guard let topElement = items.first else { fatalError("This stack is empty.") }
            return topElement
        }
    public mutating func pop() -> T {
            return items.removeFirst()
        }
    public mutating func push(_ element: T) {
            items.insert(element, at: 0)
        }
    public func count()->Int
    {
        return items.count;
    }
}
