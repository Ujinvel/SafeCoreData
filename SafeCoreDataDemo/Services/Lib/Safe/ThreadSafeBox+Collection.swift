//
//  ThreadSafeBox+Collection.swift
//  Impulse
//
//  Created by Evgeny Velichko on 01.04.2021.
//  Copyright © 2021 Genesis. All rights reserved.
//

import Foundation

precedencegroup ThreadSafeBoxAssigment {
    lowerThan: AssignmentPrecedence
}

infix operator <-: ThreadSafeBoxAssigment

extension ThreadSafeBox where Value: Collection {
    subscript(safe index: Value.Index) -> Value.Iterator.Element? {
        value.indices.contains(index) ? value[index] : nil
    }
    
    subscript(_ index: Value.Index) -> Value.Iterator.Element {
        value[index]
    }
    
    var count: Int {
        value.count
    }
    
    func forEach(_ body: (Self.Value.Element) throws -> Void) rethrows {
        try value.forEach(body)
    }
    
    func enumerated() -> EnumeratedSequence<Self.Value> {
        value.enumerated()
    }
        
    func filter(_ isIncluded: (Self.Value.Element) throws -> Bool) rethrows -> [Self.Value.Element] {
        try value.filter(isIncluded)
    }
    
    func first(where predicate: (Self.Value.Element) throws -> Bool) rethrows -> Self.Value.Element? {
        try value.first(where: predicate)
    }
    
    func map<T>(_ transform: (Self.Value.Element) throws -> T) rethrows -> [T] {
        try value.map(transform)
    }
    
    static func +<Right: Collection> (left: Self,
                                      right: Right) -> Self where Right.Element == Value.Element
    {
        with(left) {
            $0.value = Array($0.value) + right as! Self.Value
        }
    }
    
    @discardableResult static func <-<Right: Collection> (left: Self,
                                                          right: Right) -> Self where Right.Element == Value.Element
    {
        with(left) {
            $0.value = right as! Self.Value
        }
    }
}

extension ThreadSafeBox where Value: Collection, Value.Index == Int {
    var last: Self.Value.Element? {
        value[safe: value.count - 1]
    }
}
