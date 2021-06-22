//
//  Extensions.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 5/10/21.
//

import SwiftUI

extension Collection where Element: Identifiable {
    
    func firstIndex(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
    
    func contains(matching element: Element) -> Bool {
        self.contains(where: { $0.id == element.id })
    }
}

extension Set where Element: Identifiable {
    mutating func toggleMatching(element: Element) {
        if self.contains(matching: element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}

extension Data {
    // simple converter from a Data to a String
    var utf8: String? { String(data: self, encoding: .utf8 ) }
}

extension CGSize {
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
}


struct RotationModifier: AnimatableModifier {

    var rotation: Angle
    var onFullyRotated: () -> () = {}

    func body(content: Content) -> some View {
        content
        .rotationEffect(rotation)
    }
    
    var animatableData: Angle {
        get { rotation }
        set {
            rotation = newValue
            checkIfFinished()
        }
    }

    func checkIfFinished() -> () {
        if rotation == Angle.degrees(90) || rotation == Angle.zero {
            DispatchQueue.main.async {
                self.onFullyRotated()
            }
        }
    }
}

struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    private var targetValue: Value

    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        return content
    }
}

extension View {

    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}
