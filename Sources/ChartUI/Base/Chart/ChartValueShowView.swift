//
//  SwiftUIView.swift
//  
//
//  Created by Dove Zachary on 2022/1/24.
//

import SwiftUI

struct ChartValueShowView: View {
    @Environment(\.colorScheme) var currentMode
    @EnvironmentObject public var dataset: ChartDataset
    
    var chartGeometry: GeometryProxy
    
    var dataIndex: Int
    
    init(geometry: GeometryProxy, dataIndex index: Int) {
        self.chartGeometry = geometry
        self.dataIndex = index
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dataset.labels[dataIndex])
                .font(.title)
                .bold()
            ForEach(dataset.data) { dataset in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4).fill(dataset.backgroundColor)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(dataset.borderColor))
                        .frame(width: 10, height: 10, alignment: .center)
                    Text("\(dataset.label) : \((dataset.data[dataIndex] ?? 0).description)")
                        .font(.body)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(currentMode == .dark ? .black : .white)
                .shadow(color: .primary, radius: 4, x: 0, y: 0)
        )
        .transition(.opacity.animation(.default))
        .offset(x: 0, y: 0.1 * chartGeometry.size.height)
    }
}

struct ChartValueShowView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ChartValueShowView(geometry: geometry, dataIndex: 0)
                .environmentObject(ChartDataset(labels: ["labels", "123"], data: [ChartData(data: [1, 2], label: "1",
                                                                                backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                                                                borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))]))
        }
        
    }
}
