//
//  Binding.swift
//  Adwaita
//
//  Created by david-swift on 06.08.23.
//

/// A property wrapper for a property of a view that binds the property of the parent view.
///
/// ```swift
/// struct Grandparent: View {
///
///     @State private var state = false
///
///     var view: Body {
///         Parent(value: $state)
///     }
/// }
///
/// struct Parent: View {
///
///     @Binding var value: Bool
///
///     var view: Body {
///         Child(value: $value)
///     }
///
/// }
///
/// struct Child: View {
///
///     @Binding var value: Bool
///
///     var view: Body {
///         // ...
///     }
///
/// }
/// ```
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {

    /// The value.
    public var wrappedValue: Value {
        get {
            getValue()
        }
        nonmutating set {
            setValue(newValue)
            for handler in handlers {
                handler(newValue)
            }
        }
    }

    /// Get the value as a binding using the `$` prefix.
    public var projectedValue: Binding<Value> {
        .init {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }
    }

    /// The closure for getting the value.
    private let getValue: () -> Value
    /// The closure for settings the value.
    private let setValue: (Value) -> Void
    /// Handlers observing whether the binding changes.
    private var handlers: [(Value) -> Void] = []

    /// Get a property of any content of a `Binding` as a `Binding`.
    /// - Parameter dynamicMember: The path to the member.
    /// - Returns: The binding.
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        .init {
            wrappedValue[keyPath: keyPath]
        } set: { newValue in
            wrappedValue[keyPath: keyPath] = newValue
        }
    }

    /// Initialize a property that is bound from a parent view.
    /// - Parameters:
    ///   - get: The closure for getting the value.
    ///   - set: The closure for setting the value.
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.getValue = get
        self.setValue = set
    }

    /// Initialize a property that does not react to changes in the child view.
    /// - Parameters:
    ///     - value: The constant value.
    /// - Returns: The binding.
    public static func constant(_ value: Value) -> Binding<Value> {
        .init {
            value
        } set: { _ in
        }
    }

    /// Observe whether data is changed over this binding.
    /// - Parameter handler: The handler.
    /// - Returns: The binding.
    public func onSet(_ handler: @escaping (Value) -> Void) -> Self {
        var newSelf = self
        newSelf.handlers.append(handler)
        return newSelf
    }

}
