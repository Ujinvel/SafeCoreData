//
//  BaseThreadSafeBox.swift
//  Impulse
//
//  Created by Evgeny Velichko on 28.11.2019.
//  Copyright © 2019 Genesis. All rights reserved.
//

import Foundation

class BaseThreadSafeBox<Value> {
    var safeValue: Value
    
    let didGet: ThreadSafeBox.Get
    let didSet: ((Value) -> Void)?
    
    required init(value: Value,
                  didGet: ThreadSafeBox.Get = nil,
                  didSet: ((Value) -> Void)? = nil) {
        self.didGet = didGet
        self.didSet = didSet
        self.safeValue = value
    }
}
