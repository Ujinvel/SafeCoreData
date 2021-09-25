//
//  Collection+Safe.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import Foundation
    
extension Collection {
    subscript(safe index: Index) -> Iterator.Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}
