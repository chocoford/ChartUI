//
//  Utils.swift
//  
//
//  Created by Chocoford on 2022/1/2.
//

import Foundation
import SwiftUI

/// Draw Line with points defined by `values` and `step`.
/// - Parameters:
///   - values: the value of all points.
///   - step: the spacing between points.
///   - valueRatio: a ratio that multiply all `values`, like scale, default to 1.
///   - smooth: indicate that the line should be smooth or straight.
///   - close: indicate that line should be closed by `closeSubpath`.
/// - Returns: a `Path` through all points.
func drawLine(values: [Double?],
              step: CGFloat,
              valueRatio: CGFloat = 1,
//              drawPoint: Bool = true,
              smooth: Bool = false,
              close: Bool = false) -> Path {
    var path = Path()
    guard values.count > 1, let offset = values.compactMap({$0}).min() else {
        return path
    }
    
    var newLineFlag = true
    var prePoint: CGPoint = .zero
    
    for (index, value) in values.enumerated() {
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
    
    /// cannot draw point here
//    if drawPoint {
//        for (index, value) in points.enumerated() {
//            if let value = value {
//                let point = CGPoint(x: step * CGFloat(index) - 2.5,
//                                    y: CGFloat(value - offset) * valueRatio - 2.5)
//                path.addEllipse(in: .init(origin: point,
//                                          size: .init(width: 5, height: 5)))
//            }
//        }
//    }

    return path
}

func drawPoints(points: [Double?],
                step: CGFloat,
                valueRatio: CGFloat = 1) -> Path {
    Path { path in
        guard points.count > 1, let offset = points.compactMap({$0}).min() else {
            return
        }
        for (index, value) in points.enumerated() {
            if let value = value {
                let point = CGPoint(x: step * CGFloat(index) - 2.5,
                                    y: CGFloat(value - offset) * valueRatio - 2.5)
                path.addEllipse(in: .init(origin: point,
                                          size: .init(width: 5, height: 5)))
            }
        }
    }
}



func getGapValue(than value: Double, base: [Double]) -> Double {
    var initialScale: Double = 1
    
    var power: Double = 0
    let baseBase: Double = base.first!
    if pow(10, power) * baseBase > value {
        // 如果一开始就比它大，则找到第一个比它小的就是下限
        while true {
            power -= 1
            let v = pow(10, power - 1) * baseBase
            if v < value {
                initialScale = v
                break
            }
        }
        
    } else if  pow(10, power) * baseBase < value {
        // 如果一开始就比它小，则找到第一个比它大的前一个就是下限
        while true {
            power += 1
            if pow(10, power) * baseBase > value {
                initialScale = pow(10, power - 2) * baseBase
                break
            }
        }
    }

    var standards: [Double] = base.map({$0 * initialScale })
    let scale: Double = 10
    while true {
        for standard in standards {
            let scaledStandard = standard * scale
            if scaledStandard > value {
                return scaledStandard / 10
            }
        }
        standards = standards.map({$0 * scale})
    }
}
