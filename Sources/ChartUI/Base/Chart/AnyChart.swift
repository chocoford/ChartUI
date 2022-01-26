//
//  SwiftUIView.swift
//  
//
//  Created by Dove Zachary on 2022/1/27.
//

import SwiftUI

protocol AnyChart: View {

}

extension AnyChart {
    /// Attach chart options to a View
    /// - Parameter options: chart options
    /// - Returns: `View` with chart options attached
    public func chartOptions(_ options: ChartOptions) -> some View {
        self.environmentObject(options)
    }
    
    /// Attach chart dataset to a View
    /// - Parameter dataset: chart dataset
    /// - Returns: `View` with chart dataset attached
    public func data(_ dataset: ChartDataset) -> some View {
        self.environmentObject(dataset)
    }
}
