//
//  SwiftUIView.swift
//  
//
//  Created by Dove Zachary on 2022/1/10.
//

import SwiftUI

struct ChartDataLabelView: View {
    var label: String
    var backgroundColor: Color
    var borderColor: Color
    @Binding var disabled: Bool
    
    let disabledBackgroundColor: Color = .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.2)
    let disabledBorderColor: Color = .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.3)
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                Rectangle()
                    .border(disabled ? disabledBorderColor : borderColor)
                    .foregroundColor(disabled ? disabledBackgroundColor : backgroundColor)
                    .frame(width: 50, alignment: .center)
                Text(label)
                    .if(disabled, transform: { $0.strikethrough() })
                        .layoutPriority(1)
            }
            .onTapGesture {
                withAnimation {
                    disabled.toggle()
                }
            }
        }
    }
}

struct ChartDataLabelView_Previews: PreviewProvider {
    @State static var disabled: Bool = true
    static var previews: some View {
        ChartDataLabelView(label: "data 1",
                           backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                           borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8),
                           disabled: $disabled)
            .frame(height: 20, alignment: .center)
    }
}
