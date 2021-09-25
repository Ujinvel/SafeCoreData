//
//  ViewModel.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import Combine
import Foundation

class ViewModel: ObservableObject {
    
    // MARK: - Properties
    // input
    @Published var onNewItem: Date = .init()
    // output
    @Published private(set) var items: [Item] = []
    
    private var cancellable = Set<AnyCancellable>()
    // database
    private let database: Database
    // fetch
    private var fetchItems: AnyPublisher<[Item], Error> {
        ItemMO
            .all(ascending: true)
            .reactive
            .fetch(from: database)
    }
    private var observeNewItems: AnyPublisher<[Item], Error> {
        ItemMO
            .all(ascending: true)
            .reactive
            .observe(from: database)
            .map { _ in }
            .flatMap { [unowned self] _ -> AnyPublisher<[Item], Error> in self.fetchItems }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(database: Database) {
        self.database = database
        
        bindNewItemInput()
        bindItemsOutput()
    }
    
    // MARK: - Bind input
    
    private func bindNewItemInput() {
        $onNewItem
            .dropFirst()
            .sink(receiveValue: { [weak self] in
                self?.setNewItem(item: .init(id: NSUUID().uuidString, timestamp: $0))
            })
            .store(in: &cancellable)
    }
    
    // MARK: - Bind output
    
    private func bindItemsOutput() {
        fetchItems
            .merge(with: observeNewItems)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            },
            receiveValue: { [weak self] items in
                self?.items = items
            })
            .store(in: &cancellable)
    }
    
    // MARK: - Set item
    
    private func setNewItem(item: Item) {
        database
            .update(ItemMO.get(by: item.id)) { cd in
                cd.update.mapper(item)
            }
    }
}
