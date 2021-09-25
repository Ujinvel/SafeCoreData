//
//  Safe.swift
//  Impulse
//
//  Created by Evgeny Velichko on 28.10.2019.
//  Copyright © 2019 Genesis. All rights reserved.
//

import Foundation

protocol ThreadSafeBox: AnyObject {
    associatedtype Value
    
    typealias Get = (() -> Void)?
    typealias Set = ((Value) -> Void)?
    
    var value: Value { get set }
}

final class AnyThreadSafeBox<Value>: ThreadSafeBox {
    private let setValue: (Value) -> Void
    private let getValue: () -> Value
    
    var value: Value {
        get {
            getValue()
        }
        set {
            setValue(newValue)
        }
    }
    
    init<T: ThreadSafeBox>(_ box: T) where T.Value == Value {
        getValue = { box.value }
        setValue = { box.value = $0 }
    }
}
