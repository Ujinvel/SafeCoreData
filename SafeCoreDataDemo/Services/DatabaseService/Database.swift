//
//  Database.swift
//  Impulse
//
//  Created by Evgeny Velichko on 20.02.2020.
//  Copyright © 2020 Genesis. All rights reserved.
//

import CoreData

final class Database {
    private enum C {
        enum PersistentContainer {
            static let name = "SafeCoreDataDemo"
        }
    }
    
    struct Update<Request: FetchRequestWrapper> {
        typealias Entity = Request.RequestResult.Entity
        
        let entities: [Entity]
        let mapper: (Entity) -> Void
        let collectionMapper: ([Entity]) -> Void
        
        var firstEntity: Entity? {
            entities.first
        }
    }
    
    typealias UpdateBlock
        <Request: FetchRequestWrapper> = (
        update: Update<Request>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundConcurrentQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundSerialQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    typealias UpdateBlock2
        <Request1: FetchRequestWrapper, Request2: FetchRequestWrapper> = (
        update1: Update<Request1>,
        update2: Update<Request2>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundConcurrentQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundSerialQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    typealias UpdateBlock3
        <Request1: FetchRequestWrapper, Request2: FetchRequestWrapper, Request3: FetchRequestWrapper> = (
        update1: Update<Request1>,
        update2: Update<Request2>,
        update3: Update<Request3>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundConcurrentQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundSerialQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    typealias UpdateBlock4
        <Request1: FetchRequestWrapper, Request2: FetchRequestWrapper, Request3: FetchRequestWrapper, Request4: FetchRequestWrapper> = (
        update1: Update<Request1>,
        update2: Update<Request2>,
        update3: Update<Request3>,
        update4: Update<Request4>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundConcurrentQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundSerialQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    typealias UpdateBlock5
        <Request1: FetchRequestWrapper, Request2: FetchRequestWrapper, Request3: FetchRequestWrapper, Request4: FetchRequestWrapper, Request5: FetchRequestWrapper> = (
        update1: Update<Request1>,
        update2: Update<Request2>,
        update3: Update<Request3>,
        update4: Update<Request4>,
        update5: Update<Request5>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundConcurrentQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        backgroundSerialQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    // MARK: - Properties
    // shared
    static let shared = Database()
    // concurrent queue for execution performAndWait on reading
    let performConcurrentQueue = DispatchQueue(label: "Database performConcurrentQueue", qos: .userInitiated, attributes: .concurrent)
    let performSerialQueue = DispatchQueue(label: "Database performSerialQueue", qos: .userInitiated)
    // core data
    private lazy var viewContext: NSManagedObjectContext = {
        with(persistentContainer.viewContext) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }()
    private lazy var backgroundContext: NSManagedObjectContext = {
        with(persistentContainer.newBackgroundContext()) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }()
    private lazy var persistentContainer: NSPersistentContainer = NSPersistentContainer(name: C.PersistentContainer.name)
    // frc observers
    private let observers: AnyThreadSafeBox<[String: Any]> = .init(POSIXSyncThreadSafeBox(value: [:]))
    // perform write sync queue
    private let syncQueue = DispatchQueue(label: "Database syncQueue", qos: .userInitiated)
    
    // MARK: - Initialization
    
    private init() { }
    
    // MARK: - Functions
    
    func load(_ completion: @escaping (Error?) -> Void) {
        persistentContainer.loadPersistentStores { _, error in
            completion(error)
        }
    }
    
    // MARK: Add/remove observers
    
    func addObserver<T: EntityConvertable>(on fetchRequest: NSFetchRequest<T>,
                                           id: String,
                                           _ builder: ((AnyFetchResultsObserver<T.Entity>) -> Void)? = nil) throws
    {
        var err: Error?
        backgroundContext.performAndWait { [weak self] in
            self.map { `self` in
                let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                     managedObjectContext: self.backgroundContext,
                                                     sectionNameKeyPath: nil,
                                                     cacheName: id)
                var observers = self.observers.value.filter { $0.key != id }
                let observer = AnyFetchResultsObserver(FetchResultsObserver(fetchResultcontroller: frc))
                observers[id] = observer
                self.observers.value = observers
                
                do {
                    try frc.performFetch()
                } catch {
                    err = error
                }
                
                builder?(observer)
            }
        }
        
        if let error = err {
            throw error
        }
    }
    
    func removeObserver(on id: String) {
        performConcurrentQueue.async { [weak self] in
            self?.backgroundContext.performAndWait {
                self.map { `self` in
                    self.observers.value = self.observers.value.filter { $0.key != id }
                }
            }
        }
    }
    
    // MARK: Perform
    
    func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
        performConcurrentQueue.async { [unowned self] in
            self.backgroundContext.performAndWait {
                block(self.backgroundContext)
            }
        }
    }
    
    func update<Request: FetchRequestWrapper>(
        _ request: Request,
        block: @escaping (UpdateBlock<Request>) -> Void)
    {
        let mapper: (UpdateBlock5<Request, Request, Request, Request, Request>) -> Void = {
            block((update: $0.update1,
                   context: $0.context,
                   mainQueueWrapper: $0.mainQueueWrapper,
                   backgroundConcurrentQueueWrapper: $0.backgroundConcurrentQueueWrapper,
                   backgroundSerialQueueWrapper: $0.backgroundSerialQueueWrapper,
                   error: $0.error))
        }
        
        update(request, .none, .none, .none, .none, block: mapper)
    }
    
    func update<Request1: FetchRequestWrapper, Request2: FetchRequestWrapper>(
        _ request1: Request1,
        _ request2: Request2,
        block: @escaping (UpdateBlock2<Request1, Request2>) -> Void)
    {
        let mapper: (UpdateBlock5<Request1, Request2, Request1, Request1, Request1>) -> Void = {
            block((update1: $0.update1,
                   update2: $0.update2,
                   context: $0.context,
                   mainQueueWrapper: $0.mainQueueWrapper,
                   backgroundConcurrentQueueWrapper: $0.backgroundConcurrentQueueWrapper,
                   backgroundSerialQueueWrapper: $0.backgroundSerialQueueWrapper,
                   error: $0.error))
        }
        
        update(request1, request2, .none, .none, .none, block: mapper)
    }
    
    func update<Request1: FetchRequestWrapper, Request2: FetchRequestWrapper, Request3: FetchRequestWrapper>(
        _ request1: Request1,
        _ request2: Request2,
        _ request3: Request3,
        block: @escaping (UpdateBlock3<Request1, Request2, Request3>) -> Void)
    {
        let mapper: (UpdateBlock5<Request1, Request2, Request3, Request1, Request1>) -> Void = {
            block((update1: $0.update1,
                   update2: $0.update2,
                   update3: $0.update3,
                   context: $0.context,
                   mainQueueWrapper: $0.mainQueueWrapper,
                   backgroundConcurrentQueueWrapper: $0.backgroundConcurrentQueueWrapper,
                   backgroundSerialQueueWrapper: $0.backgroundSerialQueueWrapper,
                   error: $0.error))
        }
        
        update(request1, request2, request3, .none, .none, block: mapper)
    }
    
    func update<Request1: FetchRequestWrapper, Request2: FetchRequestWrapper, Request3: FetchRequestWrapper, Request4: FetchRequestWrapper>(
        _ request1: Request1,
        _ request2: Request2?,
        _ request3: Request3?,
        _ request4: Request4?,
        block: @escaping (UpdateBlock4<Request1, Request2, Request3, Request4>) -> Void)
    {
        let mapper: (UpdateBlock5<Request1, Request2, Request3, Request4, Request1>) -> Void = {
            block((update1: $0.update1,
                   update2: $0.update2,
                   update3: $0.update3,
                   update4: $0.update4,
                   context: $0.context,
                   mainQueueWrapper: $0.mainQueueWrapper,
                   backgroundConcurrentQueueWrapper: $0.backgroundConcurrentQueueWrapper,
                   backgroundSerialQueueWrapper: $0.backgroundSerialQueueWrapper,
                   error: $0.error))
        }
        
        update(request1, request2, request3, request4, .none, block: mapper)
    }
    
    func update<Request1: FetchRequestWrapper, Request2: FetchRequestWrapper, Request3: FetchRequestWrapper, Request4: FetchRequestWrapper, Request5: FetchRequestWrapper>(
        _ request1: Request1,
        _ request2: Request2?,
        _ request3: Request3?,
        _ request4: Request4?,
        _ request5: Request5?,
        block: @escaping (UpdateBlock5<Request1, Request2, Request3, Request4, Request5>) -> Void)
    {
        // syncQueue is a serial queue that ensures that only one block will be executed at a time
        syncQueue.async { [weak self] in
            self?.performWrite { context in
                // mappers
                let toManagedObjectMapper1: (Request1.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                let toManagedObjectMapper2: (Request2.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                let toManagedObjectMapper3: (Request3.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                let toManagedObjectMapper4: (Request4.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                let toManagedObjectMapper5: (Request5.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                // collection mappers
                let toManagedObjectCollectionMapper1: ([Request1.RequestResult.Entity]) -> Void = {
                    $0.forEach { entity in
                        _ = entity.toManagedObject(in: context)
                    }
                }
                let toManagedObjectCollectionMapper2: ([Request2.RequestResult.Entity]) -> Void = {
                    $0.forEach { entity in
                        _ = entity.toManagedObject(in: context)
                    }
                }
                let toManagedObjectCollectionMapper3: ([Request3.RequestResult.Entity]) -> Void = {
                    $0.forEach { entity in
                        _ = entity.toManagedObject(in: context)
                    }
                }
                let toManagedObjectCollectionMapper4: ([Request4.RequestResult.Entity]) -> Void = {
                    $0.forEach { entity in
                        _ = entity.toManagedObject(in: context)
                    }
                }
                let toManagedObjectCollectionMapper5: ([Request5.RequestResult.Entity]) -> Void = {
                    $0.forEach { entity in
                        _ = entity.toManagedObject(in: context)
                    }
                }
                // queue wrappers
                let mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void = { block in
                    DispatchQueue.main.async(execute: .init(block: block))
                }
                let backgroundConcurrentQueueWrapper: (@autoclosure @escaping () -> Void) -> Void = { block in
                    self?.performConcurrentQueue.async(execute: .init(block: block))
                }
                let backgroundSerialQueueWrapper: (@autoclosure @escaping () -> Void) -> Void = { block in
                    self?.performSerialQueue.async(execute: .init(block: block))
                }

                var entities1: [Request1.RequestResult.Entity] = []
                var entities2: [Request2.RequestResult.Entity] = []
                var entities3: [Request3.RequestResult.Entity] = []
                var entities4: [Request4.RequestResult.Entity] = []
                var entities5: [Request5.RequestResult.Entity] = []
                var coreDataError: Error?

                do {
                    entities1 = try context.fetch(request1.fetchRequest).map { $0.toEntity() }
                    
                    if let request2 = request2 {
                        entities2 = try context
                            .fetch(request2.fetchRequest)
                            .map { $0.toEntity() }
                    }
                    if let request3 = request3 {
                        entities3 = try context
                            .fetch(request3.fetchRequest)
                            .map { $0.toEntity() }
                    }
                    if let request4 = request4 {
                        entities4 = try context
                            .fetch(request4.fetchRequest)
                            .map { $0.toEntity() }
                    }
                    if let request5 = request5 {
                        entities5 = try context
                            .fetch(request5.fetchRequest)
                            .map { $0.toEntity() }
                    }
                } catch {
                    coreDataError = error
                }
                
                block((update1: .init(entities: entities1,
                                      mapper: toManagedObjectMapper1,
                                      collectionMapper: toManagedObjectCollectionMapper1),
                       update2: .init(entities: entities2,
                                      mapper: toManagedObjectMapper2,
                                      collectionMapper: toManagedObjectCollectionMapper2),
                       update3: .init(entities: entities3,
                                      mapper: toManagedObjectMapper3,
                                      collectionMapper: toManagedObjectCollectionMapper3),
                       update4: .init(entities: entities4,
                                      mapper: toManagedObjectMapper4,
                                      collectionMapper: toManagedObjectCollectionMapper4),
                       update5: .init(entities: entities5,
                                      mapper: toManagedObjectMapper5,
                                      collectionMapper: toManagedObjectCollectionMapper5),
                       context: context,
                       mainQueueWrapper: mainQueueWrapper,
                       backgroundConcurrentQueueWrapper: backgroundConcurrentQueueWrapper,
                       backgroundSerialQueueWrapper: backgroundSerialQueueWrapper,
                       error: coreDataError))
            }
        }
    }
    
    func performWrite(async: Bool = false,
                      block: @escaping (NSManagedObjectContext) -> Void)
    {
        let write: () -> Void = { [backgroundContext] in
            block(backgroundContext)
            
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        if async {
            backgroundContext.perform(write)
        } else {
            backgroundContext.performAndWait(write)
        }
    }
}
