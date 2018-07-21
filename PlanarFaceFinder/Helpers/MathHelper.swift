import UIKit

let epsilon: CGFloat = 0.01
typealias Circle = (center: CGPoint, radius: CGFloat)
typealias LineSegment = (p1: CGPoint, p2: CGPoint)

enum PointsRelation: Equatable {
    case clockwise(CGFloat)
    case counterClockwise(CGFloat)
    case inLine
}

enum QuadraticEquationSolution: Equatable {
    case twoSolutions(CGFloat, CGFloat)
    case oneSolution(CGFloat)
    case noSolution
}

enum LineSegmentCircleRelation: Equatable {
    case twoIntersections(CGPoint, CGPoint)
    case oneIntersection(CGPoint)
    case noIntersection
    
    static public func ==(lhs: LineSegmentCircleRelation, rhs: LineSegmentCircleRelation) -> Bool {
        switch (lhs, rhs) {
        case (.twoIntersections(let a, let b), .twoIntersections(let c, let d)):
            let point1IsEqual = abs(a.x - c.x) < epsilon && abs(a.y - c.y) < epsilon
            let point2IsEqual = abs(b.x - d.x) < epsilon && abs(b.y - d.y) < epsilon
            return point1IsEqual && point2IsEqual
        case (.oneIntersection(let a), .oneIntersection(let b)):
            return abs(a.x - b.x) < epsilon && abs(a.y - b.y) < epsilon
        case (.noIntersection, .noIntersection):
            return true
        default:
            return false
        }
    }
}

protocol MathHelper {
    func isLineSegment(_ lineSegment: LineSegment, contains point: CGPoint) -> Bool
    func calculateDistanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat
    func calculateYFor(m: CGFloat, x: CGFloat, c: CGFloat) -> CGFloat
    
    func intersection(of lineSegment: LineSegment, and circle: Circle) -> LineSegmentCircleRelation
    func intersection(of lineSegment1: LineSegment, and lineSegment2: LineSegment) -> CGPoint?
    
    func calculateClockwiseRatio(of point1: CGPoint, and point2: CGPoint) -> CGFloat
    func determinePointsRelation(point1: CGPoint, point2: CGPoint) -> PointsRelation
    
    func solveQuadraticEquasion(A: CGFloat, B: CGFloat, C: CGFloat) -> QuadraticEquationSolution
}

final class MathHelperImplementation: MathHelper {
    static let sharedInstance = MathHelperImplementation()
    
    func isLineSegment(_ lineSegment: LineSegment, contains point: CGPoint) -> Bool {
        // p1 + t(p2 − p1)
        let tXDenominator = lineSegment.p2.x - lineSegment.p1.x
        let tYDenominator = lineSegment.p2.y - lineSegment.p1.y
        guard tXDenominator != 0 && tYDenominator != 0 else {
            return false
        }
        
        let tX: CGFloat = (point.x - lineSegment.p1.x) / tXDenominator
        let tY: CGFloat = (point.y - lineSegment.p1.y) / tYDenominator
        
        if (abs(tX - tY) > epsilon) || tX < 0 || tX > 1 || tY < 0 || tY > 1 {
            return false
        }
        return true
    }
    
    func calculateDistanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        return (pow((point1.x - point2.x), 2) + pow((point1.y - point2.y), 2)).squareRoot()
    }
    
    func calculateYFor(m: CGFloat, x: CGFloat, c: CGFloat) -> CGFloat {
        return m * x + c
    }
    
    // https://math.stackexchange.com/a/228855
    // FIXME: what happens when we have a vertical line?
    func intersection(of lineSegment: LineSegment, and circle: Circle) -> LineSegmentCircleRelation {
        // line segment: y = mx + c
        // circle: (x − p)^2 + (y − q)^2 = r^2
        
        let mDenominator = lineSegment.p2.x - lineSegment.p1.x
        guard mDenominator != 0 else {
            return LineSegmentCircleRelation.noIntersection
        }
        
        let p = circle.center.x
        let q = circle.center.y
        
        // m = (y2 - y1) / (x2 - x1)
        let m = (lineSegment.p2.y - lineSegment.p1.y) / mDenominator
        // c = y1 - m * x1
        let c = lineSegment.p1.y - m * lineSegment.p1.x
        
        // A: (m^2 + 1)
        let A: CGFloat = pow(m, 2) + 1
        // B: 2(mc - mq - p)
        let B: CGFloat = 2 * ((m * c) - (m * q) - p)
        // C: (q^2 − r^2 + p^2 − 2cq + c^2)
        let C: CGFloat = pow(q, 2) - pow(circle.radius, 2) + pow(p, 2) - (2 * c * q) + pow(c, 2)
        
        switch solveQuadraticEquasion(A: A, B: B, C: C) {
        case .twoSolutions(let intersection1X, let intersection2X):
            let intersection1 = CGPoint(x: intersection1X, y: calculateYFor(m: m, x: intersection1X, c: c))
            let intersection2 = CGPoint(x: intersection2X, y: calculateYFor(m: m, x: intersection2X, c: c))
            print(intersection1, intersection2)
            
            switch (isLineSegment(lineSegment, contains: intersection1), isLineSegment(lineSegment, contains: intersection2)) {
            case (true, true):
                return LineSegmentCircleRelation.twoIntersections(intersection1, intersection2)
            case (true, false):
                return LineSegmentCircleRelation.oneIntersection(intersection1)
            case (false, true):
                return LineSegmentCircleRelation.oneIntersection(intersection2)
            case (false, false):
                return LineSegmentCircleRelation.noIntersection
            }
        case .oneSolution(let intersectionX):
            let intersection = CGPoint(x: intersectionX, y: calculateYFor(m: m, x: intersectionX, c: c))
            print(intersection)
            
            if isLineSegment(lineSegment, contains: intersection) {
                return LineSegmentCircleRelation.oneIntersection(intersection)
            } else {
                return LineSegmentCircleRelation.noIntersection
            }
        case .noSolution:
            return LineSegmentCircleRelation.noIntersection
        }
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
    
    func solveQuadraticEquasion(A: CGFloat, B: CGFloat, C: CGFloat) -> QuadraticEquationSolution {
        // B^2 - 4AC
        let discriminant = pow(B, 2) - (4 * A * C)
        switch discriminant {
        case _ where abs(discriminant - 0) < epsilon:
            // -B / 2A
            let solution: CGFloat = (-1 * B) / (2 * A)
            return QuadraticEquationSolution.oneSolution(solution)
        case _ where discriminant < (0 - epsilon):
            return QuadraticEquationSolution.noSolution
        default:
            // (-B - sqrt(discriminant)) / 2A
            let solution1: CGFloat = ((-1 * B) - sqrt(discriminant)) / (2 * A)
            // (-B + sqrt(discriminant)) / 2A
            let solution2: CGFloat = ((-1 * B) + sqrt(discriminant)) / (2 * A)
            return QuadraticEquationSolution.twoSolutions(solution1, solution2)
        }
    }
}
