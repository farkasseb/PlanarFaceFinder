import UIKit

protocol MathHelper {
    func isLineSegment(_ lineSegment: LineSegment, contains point: Point) -> Bool
    func calculateDistanceBetween(point1: Point, point2: Point) -> CGFloat
    func calculateYFor(m: CGFloat, x: CGFloat, c: CGFloat) -> CGFloat
    
    func intersection(of lineSegment: LineSegment, and circle: Circle) -> LineSegmentCircleRelation
    func intersection(of lineSegment1: LineSegment, and lineSegment2: LineSegment) -> Point?
    
    func orderPointsClockwiseDirection(points: [Point], from center: Point) -> [Point]
    func chooseClosestClockwisePoint(to point: Point, from points: [Point], with center: Point) -> Point?
    
    func solveQuadraticEquasion(A: CGFloat, B: CGFloat, C: CGFloat) -> QuadraticEquationSolution
}

final class MathHelperImplementation: MathHelper {
    static let sharedInstance = MathHelperImplementation()
    
    // https://stackoverflow.com/a/328122/3503324
    func isLineSegment(_ lineSegment: LineSegment, contains point: Point) -> Bool {
        // a - lineSegment.startPoint
        // b - lineSegment.endPoint
        // c - point
    
        // (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y)
        let crossProduct: CGFloat = (point.y - lineSegment.startPoint.y) * (lineSegment.endPoint.x - lineSegment.startPoint.x) - (point.x - lineSegment.startPoint.x) * (lineSegment.endPoint.y - lineSegment.startPoint.y)
        if abs(crossProduct) > epsilon {
            return false
        }
        
        // (c.x - a.x) * (b.x - a.x) + (c.y - a.y)*(b.y - a.y)
        let dotProduct: CGFloat = (point.x - lineSegment.startPoint.x) * (lineSegment.endPoint.x - lineSegment.startPoint.x) + (point.y - lineSegment.startPoint.y) * (lineSegment.endPoint.y - lineSegment.startPoint.y)
        if dotProduct < 0 {
            return false
        }
        
        let squaredLength = pow(calculateDistanceBetween(point1: lineSegment.startPoint, point2: lineSegment.endPoint), 2)
        if dotProduct > squaredLength {
            return false
        }
        
        return true
    }
    
    func calculateDistanceBetween(point1: Point, point2: Point) -> CGFloat {
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
        
        let mDenominator = lineSegment.endPoint.x - lineSegment.startPoint.x
        guard mDenominator != 0 else {
            return LineSegmentCircleRelation.noIntersection
        }
        
        let p = circle.center.x
        let q = circle.center.y
        
        // m = (y2 - y1) / (x2 - x1)
        let m = (lineSegment.endPoint.y - lineSegment.startPoint.y) / mDenominator
        // c = y1 - m * x1
        let c = lineSegment.startPoint.y - m * lineSegment.startPoint.x
        
        // A: (m^2 + 1)
        let A: CGFloat = pow(m, 2) + 1
        // B: 2(mc - mq - p)
        let B: CGFloat = 2 * ((m * c) - (m * q) - p)
        // C: (q^2 − r^2 + p^2 − 2cq + c^2)
        let C: CGFloat = pow(q, 2) - pow(circle.radius, 2) + pow(p, 2) - (2 * c * q) + pow(c, 2)
        
        switch solveQuadraticEquasion(A: A, B: B, C: C) {
        case .twoSolutions(let intersection1X, let intersection2X):
            let intersection1 = Point(x: intersection1X, y: calculateYFor(m: m, x: intersection1X, c: c))
            let intersection2 = Point(x: intersection2X, y: calculateYFor(m: m, x: intersection2X, c: c))
            
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
            let intersection = Point(x: intersectionX, y: calculateYFor(m: m, x: intersectionX, c: c))
            
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
    func intersection(of lineSegment1: LineSegment, and lineSegment2: LineSegment) -> Point? {
        // line1: p1: (x1, y1), p2: (x2, y2)
        // line2: p1: (x3, y3), p2: (x4, y4)
        
        // tA = ((y3−y4)(x1−x3) + (x4−x3)(y1−y3)) / ((x4−x3)(y1−y2) − (x1−x2)(y4−y3))
        let tANumerator: CGFloat = ((lineSegment2.startPoint.y - lineSegment2.endPoint.y) * (lineSegment1.startPoint.x - lineSegment2.startPoint.x)) + ((lineSegment2.endPoint.x - lineSegment2.startPoint.x) * (lineSegment1.startPoint.y - lineSegment2.startPoint.y))
        let tADenominator: CGFloat = ((lineSegment2.endPoint.x - lineSegment2.startPoint.x) * (lineSegment1.startPoint.y - lineSegment1.endPoint.y)) - ((lineSegment1.startPoint.x - lineSegment1.endPoint.x) * (lineSegment2.endPoint.y - lineSegment2.startPoint.y))
        guard tADenominator != 0 else {
            return nil
        }
        let tA: CGFloat = tANumerator / tADenominator
        
        // tB = ((y1−y2)(x1−x3) + (x2−x1)(y1−y3)) / ((x4−x3)(y1−y2) − (x1−x2)(y4−y3))
        let tBNumerator: CGFloat = ((lineSegment1.startPoint.y - lineSegment1.endPoint.y) * (lineSegment1.startPoint.x - lineSegment2.startPoint.x)) + ((lineSegment1.endPoint.x - lineSegment1.startPoint.x) * (lineSegment1.startPoint.y - lineSegment2.startPoint.y))
        let tBDenominator: CGFloat = ((lineSegment2.endPoint.x - lineSegment2.startPoint.x) * (lineSegment1.startPoint.y - lineSegment1.endPoint.y)) - ((lineSegment1.startPoint.x - lineSegment1.endPoint.x) * (lineSegment2.endPoint.y - lineSegment2.startPoint.y))
        guard tBDenominator != 0 else {
            return nil
        }
        let tB: CGFloat = tBNumerator / tBDenominator
        
        if tA >= 0 && tA <= 1 && tB >= 0 && tB <= 1 {
            // p1 + t(p2 − p1)
            let x: CGFloat = lineSegment1.startPoint.x + tA * (lineSegment1.endPoint.x - lineSegment1.startPoint.x)
            let y: CGFloat = lineSegment1.startPoint.y + tA * (lineSegment1.endPoint.y - lineSegment1.startPoint.y)
            return Point(x: x, y: y)
        } else {
            return nil
        }
    }
    
    // https://stackoverflow.com/a/6989383/3503324
    func orderPointsClockwiseDirection(points: [Point], from center: Point) -> [Point] {
        return points.sorted { a, b in
            if a.x - center.x >= 0 && b.x - center.x < 0 {
                return true
            }
            
            if a.x - center.x < 0 && b.x - center.x >= 0 {
                return false
            }
            
            if a.x - center.x == 0 && b.x - center.x == 0 {
                if (a.y - center.y >= 0 || b.y - center.y >= 0) {
                    return a.y > b.y
                }
                return b.y > a.y
            }
            
            // compute the cross product of vectors (center -> a) x (center -> b)
            let det = (a.x - center.x) * (b.y - center.y) - (b.x - center.x) * (a.y - center.y)
            if (det < 0) {
                return true
            }
            
            if (det > 0) {
                return false
            }
            
            // points a and b are on the same line from the center
            // check which point is closer to the center
            let d1 = (a.x - center.x) * (a.x - center.x) + (a.y - center.y) * (a.y - center.y)
            let d2 = (b.x - center.x) * (b.x - center.x) + (b.y - center.y) * (b.y - center.y)
            return d1 > d2
        }.reversed() // Cartesian --> iOS coordinate system
    }

    func chooseClosestClockwisePoint(to point: Point, from points: [Point], with center: Point) -> Point? {
        if points.count < 2 {
            return nil
        }
        
        let orderedPoints = orderPointsClockwiseDirection(points: points, from: center)
        if let indexOfOriginalPoint = orderedPoints.firstIndex(of: point) {
            switch indexOfOriginalPoint {
            case orderedPoints.count - 1:
                return orderedPoints.first
            default:
                return orderedPoints[safe: orderedPoints.index(after: indexOfOriginalPoint)]
            }
        }
        
        return nil
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
