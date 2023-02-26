//
//  ViewModelObject.swift
//  SNSMediaSearcher-iOS
//
//  Created by 佐久間昇吾 on 2023/02/26.
//

import Combine
import SwiftUI

protocol ViewModelObject: ObservableObject {
    associatedtype Input: InputObject
    associatedtype Binding: BindingObject
    associatedtype Output: OutputObject

    var input: Input { get }
    var binding: Binding { get }
    var output: Output { get }
}

extension ViewModelObject where Binding.ObjectWillChangePublisher == ObservableObjectPublisher, Output.ObjectWillChangePublisher == ObservableObjectPublisher {
    var objectWillChange: AnyPublisher<Void, Never> {
        Publishers.Merge(binding.objectWillChange, output.objectWillChange).eraseToAnyPublisher()
    }
}

// MARK: - InputObject
protocol InputObject: AnyObject {
}

// MARK: - BindingObject
protocol BindingObject: ObservableObject {
}

// MARK: - OutputObject
protocol OutputObject: ObservableObject {
}

@propertyWrapper struct BindableObject<T: BindingObject> {

    @dynamicMemberLookup struct Wrapper {
        fileprivate let binding: T
        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<T, Value>) -> Binding<Value> {
            return .init(
                get: { self.binding[keyPath: keyPath] },
                set: { self.binding[keyPath: keyPath] = $0 }
            )
        }
    }

    var wrappedValue: T

    var projectedValue: Wrapper {
        return Wrapper(binding: wrappedValue)
    }

}
