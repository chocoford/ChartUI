//
//  SwiftUIView.swift
//  
//
//  Created by Dove Zachary on 2022/2/7.
//

import SwiftUI

extension Shape {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
//    @ViewBuilder func `if`<Content: Shape>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some Shape {
//        if condition() {
//            transform(self)
//        } else {
//            self
//        }
//    }
    
    @ViewBuilder func fill<T: ShapeStyle>(with chartColor: ChartColor<T>) -> some View {
        self
            .fill(chartColor.value)
        /// plump
            .if(chartColor.isPlump, transform: { _ in
                ChartColor.plump(fill: chartColor.value) {
                    self
                }
            }, falseTransform: { _ in
                self.fill(chartColor.value)
            })
    }
}
