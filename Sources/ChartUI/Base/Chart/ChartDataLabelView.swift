//
//  SwiftUIView.swift
//  
//
//  Created by Dove Zachary on 2022/1/10.
//

import SwiftUI


struct ChartDataLabelView: View {
    var viewIndex: Int // for preference
    var height: CGFloat = 20
    var label: String
    var backgroundColor: Color
    var borderColor: Color
    @Binding var disabled: Bool
    
    let disabledBackgroundColor: Color = .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.2)
    let disabledBorderColor: Color = .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.3)
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(disabled ? disabledBorderColor : borderColor)
                        )
                        .foregroundColor(disabled ? disabledBackgroundColor : backgroundColor)
                        .frame(width: 50, alignment: .center)
                    Text(label)
                        .if(disabled, transform: { $0.strikethrough() })
                }
                .onTapGesture {
                    withAnimation {
                        disabled.toggle()
                    }
                }
                .preference(key: ChartDataLabelViewPreferenceKey.self,
                            value: [ChartDataLabelViewPreferenceData(viewIndex: self.viewIndex,
                                                                     bounds: geometry.frame(in: .named("chartLabelContainer")))])
            }.frame(width: geometry.size.width)
        }
        .frame(height: height, alignment: .center)
//        .border(.red)
        
    }
}

struct ChartDataLabelView_Previews: PreviewProvider {
    /// @State will not working here
    @State static var disabled: Bool = false
    static var previews: some View {
        ZStack {
            ChartDataLabelView(viewIndex: 0,
                               label: "data 1",
                               backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                               borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8),
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
