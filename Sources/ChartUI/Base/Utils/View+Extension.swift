import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(_ condition: @autoclosure () -> Bool,
                                          transform: @escaping (Self) -> TrueContent,
                                          falseTransform: ((Self) -> FalseContent)? = nil) -> some View {
        if condition() {
            transform(self)
        } else if falseTransform != nil {
            falseTransform!(self)
        } else {
            self
        }
    }
    
    
    @ViewBuilder func `if`<TrueContent: View>(_ condition: @autoclosure () -> Bool,
                                          transform: @escaping (Self) -> TrueContent) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func show(_ condition: @autoclosure () -> Bool) -> some View {
        if condition() {
            self
        } else {
            self
                .opacity(0)
                .frame(width: 0, height: 0, alignment: .center)
        }
    }
}
extension _ConditionalContent {

}

//struct ConditionView<TrueContent: View, FalseContent: View>: View {
//    var trueContent: TrueContent
//    var falseContent: FalseContent
//
//    init(_ view: _ConditionalContent<TrueContent, FalseContent>){
//        self.content = view
//    }
//
//    var body: some View {
//        self.content
//    }
//
//    /// Applies the given transform if the given condition evaluates to `true`.
//    /// - Parameters:
//    ///   - condition: The condition to evaluate.
//    ///   - transform: The transform to apply to the source `View`.
//    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
//    @ViewBuilder func `elseif`(_ condition: @autoclosure () -> Bool, transform: (Self) -> Self) -> Self {
//        if condition() {
//            transform(self)
//        } else {
//            self
//        }
//    }
//
//    /// Applies the given transform if the given condition evaluates to `true`.
//    /// - Parameters:
//    ///   - condition: The condition to evaluate.
//    ///   - transform: The transform to apply to the source `View`.
//    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
//    @ViewBuilder func `else`<Content: View>(transform: (Self) -> Content) -> Self {
//        transform(self)
//    }
//}
