import UIKit

let epsilon: CGFloat = 0.1

class Point: Equatable, Hashable, CustomStringConvertible {
    let x: CGFloat
    let y: CGFloat
    var tag: Int?
    var lineSegment: LineSegment?
    
    var description: String {
        var description = "x: \(x), y: \(y)"
        if let tag = tag {
            description += ", tag: \(tag)"
        }
        return description
    }
    
    init(x: CGFloat, y: CGFloat, lineSegment: LineSegment? = nil) {
        self.x = x
        self.y = y
        self.lineSegment = lineSegment
    }
    
    init(from point: CGPoint) {
        x = point.x
        y = point.y
    }
    
    static func ==(lhs: Point, rhs: Point) -> Bool {
        return MathHelperImplementation.sharedInstance.calculateDistanceBetween(point1: lhs, point2: rhs) < epsilon
    }
    
    public var hashValue: Int {
        return x.rounded().hashValue << 32 ^ y.rounded().hashValue
    }
}

extension CGPoint {
    init(from point: Point) {
        self.init()

        x = point.x
        y = point.y
    }
}

struct Circle {
    let center: Point
    let radius: CGFloat
}

class LineSegment: Equatable, Hashable {
    let startPoint: Point
    let endPoint: Point
    
    init(startPoint: Point, endPoint: Point) {
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    static func == (lhs: LineSegment, rhs: LineSegment) -> Bool {
        return (lhs.startPoint == rhs.startPoint) && (lhs.endPoint == rhs.endPoint)
    }
    
    public var hashValue: Int {
        return startPoint.hashValue << 32 ^ endPoint.hashValue
    }
}

enum QuadraticEquationSolution: Equatable {
    case twoSolutions(CGFloat, CGFloat)
    case oneSolution(CGFloat)
    case noSolution
}

enum LineSegmentCircleRelation: Equatable {
    case twoIntersections(Point, Point)
    case oneIntersection(Point)
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
