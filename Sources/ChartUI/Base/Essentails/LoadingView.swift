//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/29.
//

import SwiftUI

struct LoadingView: View {
    @State private var loading: Bool = false
    @State private var degree: CGFloat = 0
    
    var animation: Animation {
        Animation.linear(duration: 1)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1)
            .stroke(
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))]), startPoint: .topTrailing, endPoint: .bottomLeading),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
            .frame(width: 44, height: 44)
            .rotationEffect(Angle(degrees: degree))
//            .rotation3DEffect(Angle(degrees: degree / 2), axis: (x: 1, y: 0, z: 0))
            .onAppear {
                withAnimation(animation) {
                    degree = 360
                }
            }
        
        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
