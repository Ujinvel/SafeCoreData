//
//  ItemMO.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import CoreData

    // MARK: - ItemMO

@objc(ItemMO)
public class ItemMO: NSManagedObject, Identifiable {
    @NSManaged public var id: String
    @NSManaged public var timestamp: Date
}

    // MARK: - EntityConvertable

extension ItemMO: EntityConvertable {
    func toEntity() -> Item {
        .init(id: id,
              timestamp: timestamp)
    }
}
