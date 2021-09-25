//
//  DatabaseUseCase.swift
//  Impulse
//
//  Created by Evgeny Velichko on 19.02.2020.
//  Copyright © 2020 Genesis. All rights reserved.
//

import CoreData
import Combine

extension Reactive where Base: FetchRequestWrapper  {
    func observe(from dataBase: Database) -> AnyPublisher<Updates<Base.RequestResult.Entity>, Error> {
        let trigger = PassthroughSubject<Updates<Base.RequestResult.Entity>, Error>()
        let id = NSUUID().uuidString
        let perform: () -> Void = {
            do {
                try dataBase.addObserver(on: base.fetchRequest, id: id) { dbObserver in
                    dbObserver.didInsert = { entity, newIndexPath, indexPath in
                        trigger.send(Updates(insert: (entity, newIndexPath),
                                             delete: nil,
                                             update: nil,
                                             move: nil))
                    }
                    dbObserver.didDelete = { entity, newIndexPath, indexPath in
                        trigger.send(Updates(insert: nil,
                                             delete: (entity, indexPath),
                                             update: nil,
                                             move: nil))
                    }
                    dbObserver.didUpdate = { entity, newIndexPath, indexPath in
                        trigger.send(Updates(insert: nil,
                                             delete: nil,
                                             update: (entity, indexPath),
                                             move: nil))
                    }
                    dbObserver.didMove = { entity, newIndexPath, indexPath in
                        trigger.send(Updates(insert: nil,
                                             delete: nil,
                                             update: nil,
                                             move: (entity, newIndexPath, indexPath)))
                    }
                }
            } catch {
                trigger.send(completion: .failure(error))
            }
        }
        
        dataBase.performConcurrentQueue.async(execute: perform)
        
        return trigger
            .eraseToAnyPublisher()
    }
    
    func fetch(from dataBase: Database) -> AnyPublisher<[Base.RequestResult.Entity], Error> {
        let trigger = PassthroughSubject<[Base.RequestResult.Entity], Error>()
        dataBase.perform { context in
            do {
                let result = try context
                    .fetch(base.fetchRequest)
                    .map { $0.toEntity() }
                
                dataBase.performConcurrentQueue.async {
                    trigger.send(result)
                }
            } catch {
                dataBase.performConcurrentQueue.async {
                    trigger.send(completion: .failure(error))
                }
            }
        }
        
        return trigger
            .eraseToAnyPublisher()
    }
}

