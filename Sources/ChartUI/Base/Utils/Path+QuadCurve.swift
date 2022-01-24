import SwiftUI

extension Path {

	/// Returns a tiny segment of path based on percentage along the path
	///
	/// TODO: Explain why more than 1 gets 0 and why less than 0 gets 1
	/// - Parameter percent: fraction along data set, between 0.0 and 1.0 (underflow and overflow are handled)
	/// - Returns: tiny path right around the requested fraction
    func trimmedPath(for percent: CGFloat) -> Path {
        let boundsDistance: CGFloat = 0.001
        let completion: CGFloat = 1 - boundsDistance

        let pct = percent > 1 ? 0 : (percent < 0 ? 1 : percent)

		// Start/end points centered around given percentage, but capped if right at the very end
        let start = pct > completion ? completion : pct - boundsDistance
        let end = pct > completion ? 1 : pct + boundsDistance
        return trimmedPath(from: start, to: end)
    }

	/// Find the `CGPoint` for the given fraction along the path.
	///
	/// This works by requesting a very tiny trimmed section of the path, then getting the center of the bounds rectangle
	/// - Parameter percent: fraction along data set, between 0.0 and 1.0 (underflow and overflow are handled)
	/// - Returns: a `CGPoint` representing the location of that section of the path
    func point(for percent: CGFloat) -> CGPoint {
        let path = trimmedPath(for: percent)
        return CGPoint(x: path.boundingRect.midX, y: path.boundingRect.midY)
    }

    func yValue(at x: CGFloat) -> CGFloat {
        let total: CGFloat = length
        let sub: CGFloat = length(to: x)
        let percent: CGFloat = sub / total
        return point(for: percent).y
    }
    
	/// get point at `x` of the path
	/// - Parameter x: the x value of the
    func point(at x: CGFloat) -> CGPoint {
        let total = length
        let sub = length(to: x)
        let percent = sub / total
        return point(for: percent)
    }
    
	/// path length
   var length: CGFloat {
        var ret: CGFloat = 0.0
        var start: CGPoint?
        var point = CGPoint.zero
        
        forEach { ele in
            switch ele {
            case .move(let to):
                if start == nil {
                    start = to
                }
                point = to
            case .line(let to):
                ret += point.lineLength(to: to)
                point = to
            case .quadCurve(let to, let control):
                ret += point.quadCurveLength(to: to, control: control)
                point = to
            case .curve(let to, let control1, let control2):
                ret += point.bezierCurveLength(to: to, control1: control1, control2: control2)
                point = to
            case .closeSubpath:
                if let to = start {
                    ret += point.lineLength(to: to)
                    point = to
                }
                start = nil
            }
        }
        return ret
    }

	/// get length from origin to `end`
	/// - Parameter end: the end point X-axis length
	/// - Returns: the length from origin to `end`
    func length(to end: CGFloat) -> CGFloat {
        var ret: CGFloat = 0.0
        var start: CGPoint?
        var point = CGPoint.zero
        var finished = false
        
        forEach { ele in
            if finished {
                return
            }
            switch ele {
            case .move(let to):
                if to.x > end {
                    finished = true
                    return
                }
                if start == nil {
                    start = to
                }
                point = to
            case .line(let to):
                if to.x > end {
                    finished = true
                    ret += point.lineLength(to: to, x: end)
                    return
                }
                ret += point.lineLength(to: to)
                point = to
            case .quadCurve(let to, let control):
                if to.x > end {
                    finished = true
                    ret += point.quadCurveLength(to: to, control: control, x: end)
                    return
                }
                ret += point.quadCurveLength(to: to, control: control)
                point = to
            case .curve(let to, let control1, let control2):
                if to.x > end {
                    finished = true
                    ret += point.bezierCurveLength(to: to, control1: control1, control2: control2, x: end)
                    return
                }
                ret += point.bezierCurveLength(to: to, control1: control1, control2: control2)
                point = to
            case .closeSubpath:
//                fatalError("Can't include closeSubpath")
                break
            }
        }
        return ret
    }

    /// Draw a quadCurved path with an array of points.
    /// - Parameters:
    ///   - points: <#points description#>
    ///   - step: distance between each points.
    ///   - valueRatio: a ratio apply on each value in `points`, default to `1`.
    ///   - globalOffset: <#globalOffset description#>
    /// - Returns: a path draw by `addQuadCurve`
    static func quadCurvedPath(points: [Double],
                               step: CGFloat,
                               valueRatio: CGFloat = 1,
                               globalOffset: Double? = nil,
                               close: Bool = false) -> Path {
        var path = Path()
        guard points.count > 1 else {
            return path
        }
        let offset = globalOffset ?? points.min()!
        
        path.move(to: .zero)
        var point1 = CGPoint(x: 0, y: CGFloat(points[0] - offset) * valueRatio)
        
        if close {
            path.addLine(to: point1)
        } else {
            path.move(to: point1)
        }


        for pointIndex in 1..<points.count {
            let point2 = CGPoint(x: step * CGFloat(pointIndex), y: CGFloat(points[pointIndex] - offset) * valueRatio)
            let midPoint = CGPoint.getMidPoint(firstPoint: point1, secondPoint: point2)
            path.addQuadCurve(to: midPoint, control: CGPoint.getControlPoint(firstPoint: midPoint, secondPoint: point1))
            path.addQuadCurve(to: point2, control: CGPoint.getControlPoint(firstPoint: midPoint, secondPoint: point2))
            point1 = point2
        }
        if close {
            path.addLine(to: CGPoint(x: point1.x, y: 0))
            path.closeSubpath()
        }
        return path
    }

	/// Draw a path with an array of points.
	/// - Parameters:
	///   - points: An array of `Double`, indicating the points value.
	///   - step: offsets of X direction distance between each points.
	/// - Returns: <#description#>
    static func linePath(points: [Double], step: CGPoint) -> Path {
        var path = Path()
        if points.count < 2 {
            return path
        }
        guard let offset = points.min() else {
            return path
        }
        let point1 = CGPoint(x: 0, y: CGFloat(points[0] - offset) * step.y)
        path.move(to: point1)
        for pointIndex in 1..<points.count {
            let point2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
            path.addLine(to: point2)
        }
        return path
    }

	/// <#Description#>
	/// - Parameters:
	///   - points: <#points description#>
	///   - step: <#step description#>
	/// - Returns: <#description#>
    static func closedLinePathWithPoints(points: [Double], step: CGPoint) -> Path {
        var path = Path()
        if points.count < 2 {
            return path
        }
        guard let offset = points.min() else {
            return path
        }
        var point1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
        path.move(to: point1)
        for pointIndex in 1..<points.count {
            point1 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
            path.addLine(to: point1)
        }
        path.addLine(to: CGPoint(x: point1.x, y: 0))
        path.closeSubpath()
        return path
    }
    
}

extension CGPoint {

	/// get the point at the line which is from `self` to `to`  at `x`.
    func point(to: CGPoint, x: CGFloat) -> CGPoint {
        let k = (to.y - self.y) / (to.x - self.x)
        let y = self.y + (x - self.x) * k
        return CGPoint(x: x, y: y)
    }

	/// get length of the line from `self` to `to`, trim by `x`
    func lineLength(to: CGPoint, x: CGFloat? = nil) -> CGFloat {
        if x != nil {
            return dist(to: point(to: to, x: x!))
        } else {
            return dist(to: to)
        }
    }

	/// Get quad curve length from `self` to `to`, divided by `x`
    ///
    /// divide quadCurve to many small straight lines.
    func quadCurveLength(to: CGPoint, control: CGPoint, x: CGFloat? = nil) -> CGFloat {
        var dist: CGFloat = 0
        let steps: CGFloat = 100
        
        for i in 0..<Int(steps) {
            let t0 = CGFloat(i) / steps
            let t1 = CGFloat(i+1) / steps
            let a = point(to: to, t: t0, control: control)
            let b = point(to: to, t: t1, control: control)
            if let x = x {
                if a.x >= x {
                    return dist
                } else if b.x > x {
                    dist += a.lineLength(to: b, x: x)
                    return dist
                } else if b.x == x {
                    dist += a.lineLength(to: b)
                    return dist
                }
            }
            
            dist += a.lineLength(to: b)
        }
        return dist
    }

	/// get the point to `to` at a quad curve with control point `control`.
    func point(to: CGPoint, t: CGFloat, control: CGPoint) -> CGPoint {
        let x = CGPoint.value(x: self.x, y: to.x, t: t, c: control.x)
        let y = CGPoint.value(x: self.y, y: to.y, t: t, c: control.y)
        
        return CGPoint(x: x, y: y)
    }


    func bezierCurveLength(to: CGPoint, control1: CGPoint, control2: CGPoint, x: CGFloat? = nil) -> CGFloat {
        var dist: CGFloat = 0
        let steps: CGFloat = 100
        
        for i in 0..<Int(steps) {
            let t0 = CGFloat(i) / steps
            let t1 = CGFloat(i+1) / steps
            
            let a = point(to: to, t: t0, control1: control1, control2: control2)
            let b = point(to: to, t: t1, control1: control1, control2: control2)
            if let x = x {
                if a.x >= x {
                    return dist
                } else if b.x > x {
                    dist += a.lineLength(to: b, x: x)
                    return dist
                } else if b.x == x {
                    dist += a.lineLength(to: b)
                    return dist
                }
            }

            dist += a.lineLength(to: b)
        }
        
        return dist
    }


    func point(to: CGPoint, t: CGFloat, control1: CGPoint, control2: CGPoint) -> CGPoint {
        let x = CGPoint.value(x: self.x, y: to.x, t: t, control1: control1.x, control2: control2.x)
        let y = CGPoint.value(x: self.y, y: to.y, t: t, control1: control1.y, control2: control2.x)
        
        return CGPoint(x: x, y: y)
    }

	/// <#Description#>
	/// - Parameters:
	///   - x: <#x description#>
	///   - y: <#y description#>
	///   - t: <#t description#>
	///   - c: <#c description#>
	/// - Returns: <#description#>
    static func value(x: CGFloat, y: CGFloat, t: CGFloat, c: CGFloat) -> CGFloat {
        var value: CGFloat = 0.0
        // (1-t)^2 * p0 + 2 * (1-t) * t * c1 + t^2 * p1
        value += pow(1-t, 2) * x
        value += 2 * (1-t) * t * c
        value += pow(t, 2) * y
        return value
    }

	/// <#Description#>
	/// - Parameters:
	///   - x: <#x description#>
	///   - y: <#y description#>
	///   - t: <#t description#>
	///   - control1: <#control1 description#>
	///   - control2: <#control2 description#>
	/// - Returns: <#description#>
    static func value(x: CGFloat, y: CGFloat, t: CGFloat, control1: CGFloat, control2: CGFloat) -> CGFloat {
        var value: CGFloat = 0.0
        // (1-t)^3 * p0 + 3 * (1-t)^2 * t * c1 + 3 * (1-t) * t^2 * c2 + t^3 * p1
        value += pow(1-t, 3) * x
        value += 3 * pow(1-t, 2) * t * control1
        value += 3 * (1-t) * pow(t, 2) * control2
        value += pow(t, 3) * y
        return value
    }


    func dist(to: CGPoint) -> CGFloat {
        return sqrt((pow(self.x - to.x, 2) + pow(self.y - to.y, 2)))
    }

    static func getMidPoint(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        return CGPoint(
            x: (firstPoint.x + secondPoint.x) / 2,
            y: (firstPoint.y + secondPoint.y) / 2)
    }

	/// get the control point with two points
    static func getControlPoint(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        var controlPoint = CGPoint.getMidPoint(firstPoint: firstPoint, secondPoint: secondPoint)
        let diffY = abs(secondPoint.y - controlPoint.y)
        
        if firstPoint.y < secondPoint.y {
            controlPoint.y += diffY
        } else if firstPoint.y > secondPoint.y {
            controlPoint.y -= diffY
        }
        return controlPoint
    }
}
