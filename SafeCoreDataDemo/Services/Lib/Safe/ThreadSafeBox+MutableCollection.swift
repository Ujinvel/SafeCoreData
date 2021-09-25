//
//  ThreadSafeBox+MutableCollection.swift
//  Impulse
//
//  Created by Evgeny Velichko on 01.04.2021.
//  Copyright © 2021 Genesis. All rights reserved.
//

import Foundation

extension ThreadSafeBox where Value: MutableCollection {
    subscript(safe index: Value.Index) -> Value.Iterator.Element? {
        get {
            value.indices.contains(index) ? value[index] : nil
        }
        set {
            if value.indices.contains(index),
                let newValue = newValue {
                value = with(value) {
                    $0[index] = newValue
                }
            }
        }
    }
}
