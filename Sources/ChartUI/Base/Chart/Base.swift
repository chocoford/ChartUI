//
//  Base.swift
//  
//
//  Created by Dove Zachary on 2022/1/27.
//

import SwiftUI

struct AnyChart<Content: View>: ChartView {
    var content: Content
    
    init(_ view: Content){
        self.content = view
    }
    
    var body: some View {
        self.content
    }
}

protocol ChartView: View {
    
}

extension ChartView {
    /// Attach chart options to a View
    /// - Parameter options: chart options
    /// - Returns: `View` with chart options attached
    public func options(_ options: ChartOptions) -> some ChartView {
        AnyChart(self.environmentObject(options))
    }
    
    /// Attach chart dataset to a View
    /// - Parameter dataset: chart dataset
    /// - Returns: `View` with chart dataset attached
    public func data(_ dataset: ChartDataset) -> some ChartView {
        AnyChart(self.environmentObject(dataset))
    }
}
