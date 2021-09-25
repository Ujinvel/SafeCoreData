//
//  ManagedObjectConvertible.swift
//  Impulse
//
//  Created by Anton Kozlovskyi on 1/17/19.
//  Copyright © 2019 Genesis. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectConvertible {
    typealias ErrorCompletion = (Error?) -> Void
    
    associatedtype ManagedObject: EntityConvertable
    func toManagedObject(in context: NSManagedObjectContext) -> ManagedObject?
}


