//
//  Reactive.swift
//  SafeCoreDataDemo
//
//  Created by Ujin Vel on 25.09.2021.
//

import Foundation

//Use `Reactive` proxy as customization point for constrained protocol extensions.
//
//General pattern would be:
//
//// 1. Extend Reactive protocol with constrain on Base
//// Read as: Reactive Extension where Base is a SomeType
//extension Reactive where Base: SomeType {
//// 2. Put any specific reactive extension for SomeType here
//}
//
//With this approach we can have more specialized methods and properties using
//`Base` and not just specialized on common base type.
//
//*/

public struct Reactive<Base> {
   /// Base object to extend.
   public let base: Base

   /// Creates extensions with base object.
   ///
   /// - parameter base: Base object.
   public init(_ base: Base) {
       self.base = base
   }
}

/// A type that has reactive extensions.
public protocol ReactiveCompatible {
   /// Extended type
   associatedtype ReactiveBase

   @available(*, deprecated, renamed: "ReactiveBase")
   typealias CompatibleType = ReactiveBase

   /// Reactive extensions.
   static var reactive: Reactive<ReactiveBase>.Type { get set }

   /// Reactive extensions.
   var reactive: Reactive<ReactiveBase> { get set }
}

extension ReactiveCompatible {
   /// Reactive extensions.
   public static var reactive: Reactive<Self>.Type {
       get {
           return Reactive<Self>.self
       }
       // swiftlint:disable:next unused_setter_value
       set {
           // this enables using Reactive to "mutate" base type
       }
   }

   /// Reactive extensions.
   public var reactive: Reactive<Self> {
       get {
           return Reactive(self)
       }
       // swiftlint:disable:next unused_setter_value
       set {
           // this enables using Reactive to "mutate" base object
       }
   }
}

import class Foundation.NSObject

/// Extend NSObject with `rx` proxy.
extension NSObject: ReactiveCompatible { }

