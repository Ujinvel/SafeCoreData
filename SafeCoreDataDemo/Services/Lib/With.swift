//
//  With.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import Foundation

@discardableResult public func with<T>(_ value: T,
                                       _ builder: (inout T) -> Void) -> T
{
    var mutableValue = value
    
    builder(&mutableValue)
    
    return mutableValue
}
