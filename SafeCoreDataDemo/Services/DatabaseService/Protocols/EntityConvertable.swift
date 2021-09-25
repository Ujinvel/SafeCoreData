//
//  EntityConvertable.swift
//  Impulse
//
//  Created by Anton Kozlovskyi on 1/17/19.
//  Copyright © 2019 Genesis. All rights reserved.
//

import Foundation
import CoreData

protocol EntityConvertable where Self: NSManagedObject {
    associatedtype Entity: ManagedObjectConvertible
    func toEntity() -> Entity
}
