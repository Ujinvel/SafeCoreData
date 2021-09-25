//
//  FetchRequest.swift
//  Impulse
//
//  Created by Evgeny Velichko on 21.02.2020.
//  Copyright © 2020 Genesis. All rights reserved.
//

import Foundation
import CoreData

protocol FetchRequestWrapper where Self: NSObject {
    associatedtype RequestResult: EntityConvertable
    
    var fetchRequest: NSFetchRequest<RequestResult> { get }
}

final class AnyFetchRequest<T: EntityConvertable>: NSObject, FetchRequestWrapper {
    typealias RequestResult = T
    
    let fetchRequest: NSFetchRequest<T>
    
    init(_ fetchRequest: NSFetchRequest<T>) {
        self.fetchRequest = fetchRequest
        
        super.init()
    }
}
