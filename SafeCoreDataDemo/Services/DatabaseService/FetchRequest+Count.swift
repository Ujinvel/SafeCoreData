//
//  FetchRequest+Count.swift
//  Impulse
//
//  Created by Evgeny Velichko on 06.04.2021.
//  Copyright © 2021 Genesis. All rights reserved.
//

import CoreData

extension FetchRequestWrapper {
    func count(in context: NSManagedObjectContext) throws -> Int {
        try context.count(for: fetchRequest)
    }
    
    func isEmpty(in context: NSManagedObjectContext) -> Bool {
        (try? count(in: context) == 0) ?? false
    }
}
