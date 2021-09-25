//
//  Item.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import CoreData

    // MARK: - Item

struct Item: Identifiable {
    typealias ID = String
    
    let id: ID
    let timestamp: Date

    
    // MARK: - Initialization
    
    init(id: ID,
         timestamp: Date)
    {
        self.id = id
        self.timestamp = timestamp
    }
}

    // MARK: - ManagedObjectConvertible

extension Item: ManagedObjectConvertible {
    func toManagedObject(in context: NSManagedObjectContext) -> ItemMO? {
        with(firstOrCreate(context: context)) {
            $0.timestamp = timestamp
        }
    }
}
