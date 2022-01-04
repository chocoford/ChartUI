//
//  Utils.swift
//  
//
//  Created by Chocoford on 2022/1/2.
//

import Foundation
import SwiftUI

func drawLine(points: [Double?],
              step: CGFloat,
              valueRatio: CGFloat = 1,
              drawPoint: Bool = true,
              smooth: Bool = false,
              close: Bool = false) -> Path {
    var path = Path()
    guard points.count > 1, let offset = points.compactMap({$0}).min() else {
        return path
    }
    
    var newLineFlag = true
    var prePoint: CGPoint = .zero
    
    for (index, value) in points.enumerated() {
        if let value = value {
            let point = CGPoint(x: step * CGFloat(index), y: CGFloat(value - offset) * valueRatio)
            
            if newLineFlag {
                newLineFlag = false
                if close {
                    path.move(to: .init(x: point.x, y: 0))
                    path.addLine(to: point)
                } else {
                    path.move(to: point)
                }
            } else {
                if smooth {
                    let point = CGPoint(x: step * CGFloat(index), y: CGFloat(value - offset) * valueRatio)
                    let midPoint = CGPoint.getMidPoint(firstPoint: prePoint, secondPoint: point)
                    path.addQuadCurve(to: midPoint, control: CGPoint.getControlPoint(firstPoint: midPoint, secondPoint: prePoint))
                    path.addQuadCurve(to: point, control: CGPoint.getControlPoint(firstPoint: midPoint, secondPoint: point))
                } else {
                    path.addLine(to: point)
                }
            }
            prePoint = point
        } else {
            newLineFlag = true
            // close the path
            if close {
                path.addLine(to: CGPoint(x: prePoint.x, y: 0))
                path.closeSubpath()
            }
        }
    }
    
    if close {
        path.addLine(to: CGPoint(x: prePoint.x, y: 0))
//        path.addLine(to: .zero)
        path.closeSubpath()
    }
    
    
    if drawPoint {
        for (index, value) in points.enumerated() {
            if let value = value {
                let point = CGPoint(x: step * CGFloat(index) - 2.5,
                                    y: CGFloat(value - offset) * valueRatio - 2.5)
                path.addEllipse(in: .init(origin: point,
                                          size: .init(width: 5, height: 5)))
            }
        }
    }

    return path
}
