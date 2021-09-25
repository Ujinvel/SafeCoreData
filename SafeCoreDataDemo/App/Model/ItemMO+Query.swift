//
//  ItemMO+Query.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import CoreData

extension ItemMO {
    static func all(offset: Int? = nil,
                    limit: Int? = nil,
                    ascending: Bool) -> AnyFetchRequest<ItemMO>
    {
        with(AnyFetchRequest(NSFetchRequest<ItemMO>(entityName: String(describing: ItemMO.self)))) { anyRequest in
            // sortDescriptors is mandatory for use in FRC
            anyRequest.fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ItemMO.timestamp, ascending: ascending)]
            offset.map { anyRequest.fetchRequest.fetchOffset = $0 }
            limit.map { anyRequest.fetchRequest.fetchLimit = $0 }
        }
    }
    
    static func get(by id: Item.ID) -> AnyFetchRequest<ItemMO> {
        with(AnyFetchRequest(NSFetchRequest<ItemMO>(entityName: String(describing: ItemMO.self)))) { anyRequest in
            // sortDescriptors is mandatory for use in FRC
            anyRequest.fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ItemMO.timestamp, ascending: true)]
            anyRequest.fetchRequest.predicate = .init(format: "id = %d", id)
            anyRequest.fetchRequest.fetchLimit = 1
        }
    }
}
