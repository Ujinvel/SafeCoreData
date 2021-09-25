//
//  ManagedObjectConvertible+Create.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import CoreData

extension NSManagedObject {
    fileprivate class var entityName: String {
        let name = NSStringFromClass(self)
        return name.components(separatedBy: ".").last ?? ""
    }
    
    static func createFetchRequest<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil)
        -> NSFetchRequest<T>
    {
        
        let request = NSFetchRequest<T>(entityName: self.entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        return request
    }
    
    func setCustomValue(_ value: Any?, for key: String) {
        willChangeValue(forKey: key)
        defer { didChangeValue(forKey: key) }
        setPrimitiveValue(value, forKey: key)
    }
    
    func customValue(for key: String) -> Any? {
        willAccessValue(forKey: key)
        defer { didAccessValue(forKey: key) }
        return primitiveValue(forKey: key)
    }
}

extension ManagedObjectConvertible where Self: Identifiable, Self.ID == String {
    var predicate: NSPredicate {
        .init(format: "id == %@", ("\(id)"))
    }
    
    func firstOrCreate(context: NSManagedObjectContext) -> ManagedObject where ManagedObject: Identifiable, ManagedObject.ID == Self.ID
    {
                
        if let first = all(context: context).first {
            return first
        } else {
            if let entity = NSEntityDescription.entity(forEntityName: ManagedObject.entityName, in: context) {
                return with(ManagedObject(entity: entity, insertInto: context) as ManagedObject) {
                    $0.setCustomValue(id, for: "id")
                }
            } else {
                fatalError()
            }
        }
    }
    
    func all(orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
             ascending: Bool = true,
             context: NSManagedObjectContext) -> [ManagedObject]
    {
        let request = ManagedObject.createFetchRequest(predicate: predicate,
                                                       sortDescriptors: sortDescriptors)
        
        return ((try? context.fetch(request) as? [ManagedObject])?.optional ?? [])
    }
}

