//
//  SwiftUIView.swift
//  
//
//  Created by Dove Zachary on 2022/1/10.
//

import SwiftUI

// TODO: Support `ShapeStyle` generic type for ChartColor
struct ChartDataLabelView: View {
    var viewIndex: Int // for preference
    var height: CGFloat = 14
    var label: String
    var backgroundColor: ChartColor<Color>
    var borderColor: ChartColor<Color>
    @Binding var disabled: Bool
    
    let disabledBackgroundColor: ChartColor = .init(color: .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.2))
    let disabledBorderColor: ChartColor = .init(color: .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.3))
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(with: disabled ? disabledBackgroundColor : backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .if(disabled, transform: { shape in
                            shape.stroke(disabledBorderColor.value)
                        }, falseTransform: { shape in
                            shape.stroke(borderColor.value)
                        })
                )
                .fixedSize()
            Text(label)
                .if(disabled, transform: { $0.strikethrough() })
        }
        .onTapGesture {
            withAnimation {
                disabled.toggle()
            }
        }
        //                .preference(key: ChartDataLabelViewPreferenceKey.self,
        //                            value: [ChartDataLabelViewPreferenceData(viewIndex: self.viewIndex,
        //                                                                     bounds: geometry.frame(in: .named("chartLabelContainer")))])
        }
}

struct ChartDataLabelView_Previews: PreviewProvider {
    /// @State will not working here
    @State static var disabled: Bool = false
    static var previews: some View {
        ZStack {
            ChartDataLabelView(viewIndex: 0,
                               label: "data 1",
                               backgroundColor: .init(color: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2)),
                               borderColor: .init(color: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8)),
                               disabled: $disabled)
        }
        .frame(width: 400, height: 400, alignment: .center)
//        .border(.red)
    }
}

struct ChartDataLabelViewPreferenceKey: PreferenceKey {
    typealias Value = [ChartDataLabelViewPreferenceData]
    
    static var defaultValue: [ChartDataLabelViewPreferenceData] = []
    
    static func reduce(value: inout [ChartDataLabelViewPreferenceData], nextValue: () -> [ChartDataLabelViewPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}


struct ChartDataLabelViewPreferenceData: Identifiable, Equatable {
    let id = UUID() // required when using ForEach later
    let viewIndex: Int
    let bounds: CGRect//Anchor<>
}
