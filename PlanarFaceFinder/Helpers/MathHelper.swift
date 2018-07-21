import UIKit

let epsilon: CGFloat = 0.01
typealias Circle = (center: CGPoint, radius: CGFloat)
typealias LineSegment = (p1: CGPoint, p2: CGPoint)

enum PointsRelation: Equatable {
    case clockwise(CGFloat)
    case counterClockwise(CGFloat)
    case inLine
}

enum LineSegmentCircleRelation {
    case intersects(CGPoint, CGPoint)
    case tangent(CGPoint)
    case miss
}

protocol MathHelper {
    func calculateDistanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat
    
    func intersection(of lineSegment: LineSegment, and circle: Circle) -> LineSegmentCircleRelation
    func intersection(of lineSegment1: LineSegment, and lineSegment2: LineSegment) -> CGPoint?
    
    func calculateClockwiseRatio(of point1: CGPoint, and point2: CGPoint) -> CGFloat
    func determinePointsRelation(point1: CGPoint, point2: CGPoint) -> PointsRelation
    
    func solveQuadraticEquasion(a: CGFloat, b: CGFloat, c: CGFloat) -> (CGFloat?, CGFloat?)
}

final class MathHelperImplementation: MathHelper {
    func calculateDistanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        return (pow((point1.x - point2.x), 2) + pow((point1.y - point2.y), 2)).squareRoot()
    }
    
    // https://math.stackexchange.com/a/228855
    func intersection(of lineSegment: LineSegment, and circle: Circle) -> LineSegmentCircleRelation {
        // m = (y2 - y1) / (x2 - x1)
        // c = y1 - m * x1
        
        // A: (m^2 + 1)
        // B: (mc - mq - p)
        // C: (q^2 − r^2 + p^2 − 2cq + c^2)
        
        return LineSegmentCircleRelation.miss
    }
    
    // http://www.cs.swan.ac.uk/~cssimon/line_intersection.html
    func intersection(of lineSegment1: LineSegment, and lineSegment2: LineSegment) -> CGPoint? {
        // line1: p1: (x1, y1), p2: (x2, y2)
        // line2: p1: (x3, y3), p2: (x4, y4)
        
        // tA = ((y3−y4)(x1−x3) + (x4−x3)(y1−y3)) / ((x4−x3)(y1−y2) − (x1−x2)(y4−y3))
        let tANumerator: CGFloat = ((lineSegment2.p1.y - lineSegment2.p2.y) * (lineSegment1.p1.x - lineSegment2.p1.x)) + ((lineSegment2.p2.x - lineSegment2.p1.x) * (lineSegment1.p1.y - lineSegment2.p1.y))
        let tADenominator: CGFloat = ((lineSegment2.p2.x - lineSegment2.p1.x) * (lineSegment1.p1.y - lineSegment1.p2.y)) - ((lineSegment1.p1.x - lineSegment1.p2.x) * (lineSegment2.p2.y - lineSegment2.p1.y))
        guard tADenominator != 0 else {
            return nil
        }
        let tA: CGFloat = tANumerator / tADenominator
        
        // tB = ((y1−y2)(x1−x3) + (x2−x1)(y1−y3)) / ((x4−x3)(y1−y2) − (x1−x2)(y4−y3))
        let tBNumerator: CGFloat = ((lineSegment1.p1.y - lineSegment1.p2.y) * (lineSegment1.p1.x - lineSegment2.p1.x)) + ((lineSegment1.p2.x - lineSegment1.p1.x) * (lineSegment1.p1.y - lineSegment2.p1.y))
        let tBDenominator: CGFloat = ((lineSegment2.p2.x - lineSegment2.p1.x) * (lineSegment1.p1.y - lineSegment1.p2.y)) - ((lineSegment1.p1.x - lineSegment1.p2.x) * (lineSegment2.p2.y - lineSegment2.p1.y))
        guard tBDenominator != 0 else {
            return nil
        }
        let tB: CGFloat = tBNumerator / tBDenominator
        
        if tA >= 0 && tA <= 1 && tB >= 0 && tB <= 1 {
            // p1 + t(p2 − p1)
            let x: CGFloat = lineSegment1.p1.x + tA * (lineSegment1.p2.x - lineSegment1.p1.x)
            let y: CGFloat = lineSegment1.p1.y + tA * (lineSegment1.p2.y - lineSegment1.p1.y)
            return CGPoint(x: x, y: y)
        } else {
            return nil
        }
    }
    
    // https://stackoverflow.com/a/1165943/3503324
    func calculateClockwiseRatio(of point1: CGPoint, and point2: CGPoint) -> CGFloat {
        // (x2 − x1)(y2 + y1)
        return (point2.x - point1.x) * (point2.y + point1.y)
    }
    
    func determinePointsRelation(point1: CGPoint, point2: CGPoint) -> PointsRelation {
        let ratio = calculateClockwiseRatio(of: point1, and: point2)
        switch ratio {
        case let clockwiseRatio where ratio > 0:
            return PointsRelation.clockwise(clockwiseRatio)
        case let counterClockwiseRatio where ratio < 0:
            return PointsRelation.counterClockwise(counterClockwiseRatio)
        default:
            return PointsRelation.inLine
        }
    }
    
    func solveQuadraticEquasion(a: CGFloat, b: CGFloat, c: CGFloat) -> (CGFloat?, CGFloat?) {
        // b^2 - 4ac
        let discriminant = pow(b, 2) - (4 * a * c)
        
        if discriminant < 0 {
            return (nil, nil)
        }
        
        if discriminant < epsilon {
            // -b / 2a
            let solution: CGFloat = (-1 * b) / (2 * a)
            return (solution, nil)
        }
        
        // (-b - sqrt(discriminant)) / 2a
        let solution1: CGFloat = ((-1 * b) - sqrt(discriminant)) / (2 * a)
        // (-b + sqrt(discriminant)) / 2a
        let solution2: CGFloat = ((-1 * b) + sqrt(discriminant)) / (2 * a)
        return (solution1, solution2)
    }
}
