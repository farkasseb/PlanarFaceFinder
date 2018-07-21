import XCTest
@testable import PlanarFaceFinder

class MathHelperTests: XCTestCase {
    
    var mathHelper: MathHelper!
    
    override func setUp() {
        super.setUp()
        
        mathHelper = MathHelperImplementation()
    }
    
    // MARK: isLineSegment
    
    func test_isLineSegment_containsStartPoint() {
        let startPoint = CGPoint(x: 1, y: 1)
        let lineSegment = (p1: startPoint, p2: CGPoint(x: 3, y: 3))
        
        XCTAssertTrue(mathHelper.isLineSegment(lineSegment, contains: startPoint))
    }
    
    func test_isLineSegment_containsEndPoint() {
        let endPoint = CGPoint(x: 3, y: 3)
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: endPoint)
        
        XCTAssertTrue(mathHelper.isLineSegment(lineSegment, contains: endPoint))
    }
    
    func test_isLineSegment_containsPoint() {
        let point = CGPoint(x: 2, y: 2)
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        
        XCTAssertTrue(mathHelper.isLineSegment(lineSegment, contains: point))
    }
    
    func test_isLineSegment_notContainsPointWhichIsOnTheLine() {
        let point = CGPoint(x: 4, y: 4)
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        
        XCTAssertFalse(mathHelper.isLineSegment(lineSegment, contains: point))
    }
    
    func test_isLineSegment_notContainsPointWhichIsNotOnTheLine() {
        let point = CGPoint(x: 1, y: 3)
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        
        XCTAssertFalse(mathHelper.isLineSegment(lineSegment, contains: point))
    }
    
    // MARK: calculateDistanceBetween
    
    func test_calculateDistanceBetween_zero() {
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 0, y: 0)
        
        XCTAssertEqual(mathHelper.calculateDistanceBetween(point1: point1, point2: point2), 0)
    }
    
    func test_calculateDistanceBetween_example1() {
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 0, y: 1)
        
        XCTAssertEqual(mathHelper.calculateDistanceBetween(point1: point1, point2: point2), 1)
    }
    
    func test_calculateDistanceBetween_example2() {
        // Pythagorean triple
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 3, y: 4)
        
        XCTAssertEqual(mathHelper.calculateDistanceBetween(point1: point1, point2: point2), 5)
    }
    
    // MARK: calculateYFor
    
    func test_calculateYFor_example1() {
        let m: CGFloat = 1/2
        let x: CGFloat = 2
        let c: CGFloat = 3
        
        XCTAssertEqual(mathHelper.calculateYFor(m: m, x: x, c: c), 4)
    }
    
    func test_calculateYFor_example2() {
        let m: CGFloat = 2/3
        let x: CGFloat = 3
        let c: CGFloat = 1/2
        
        XCTAssertEqual(mathHelper.calculateYFor(m: m, x: x, c: c), 2.5)
    }
    
    // MARK: intersectionOfLineSegmentAndCircle
    
    func test_intersectionOfLineSegmentAndCircle_noIntersection() {
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let circle: (CGPoint, CGFloat) = (center: CGPoint(x: 0, y: 0), radius: 1)
        
        let solution = LineSegmentCircleRelation.noIntersection
        let calculatedSolution = mathHelper.intersection(of: lineSegment, and: circle)
        XCTAssertEqual(calculatedSolution, solution)
    }
    
    func test_intersectionOfLineSegmentAndCircle_oneIntersection() {
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let circle: (CGPoint, CGFloat) = (center: CGPoint(x: 1, y: 1), radius: 1)
        
        let solution = LineSegmentCircleRelation.oneIntersection(CGPoint(x: 1.7, y: 1.7))
        let calculatedSolution = mathHelper.intersection(of: lineSegment, and: circle)
        XCTAssertEqual(calculatedSolution, solution)
    }
    
    func test_intersectionOfLineSegmentAndCircle_tangentIntersection() {
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let circle: (CGPoint, CGFloat) = (center: CGPoint(x: 1, y: 0), radius: 1)
        
        let solution = LineSegmentCircleRelation.oneIntersection(CGPoint(x: 1, y: 1))
        let calculatedSolution = mathHelper.intersection(of: lineSegment, and: circle)
        XCTAssertEqual(calculatedSolution, solution)
    }
    
    func test_intersectionOfLineSegmentAndCircle_twoIntersections() {
        let lineSegment = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let circle: (CGPoint, CGFloat) = (center: CGPoint(x: 2, y: 2), radius: 1)
        
        let solution = LineSegmentCircleRelation.twoIntersections(CGPoint(x: 1.29, y: 1.29), CGPoint(x: 2.7, y: 2.7))
        let calculatedSolution = mathHelper.intersection(of: lineSegment, and: circle)
        XCTAssertEqual(calculatedSolution, solution)
    }
    
    // MARK: intersectionOfLineSegments
    
    func test_intersectionOfLineSegments_noIntersection() {
        let line1 = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let line2 = (p1: CGPoint(x: 3, y: 1), p2: CGPoint(x: 5, y: 3))
        
        XCTAssertNil(mathHelper.intersection(of: line1, and: line2))
    }
    
    func test_intersectionOfLineSegments_intersection() {
        let line1 = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let line2 = (p1: CGPoint(x: 1, y: 3), p2: CGPoint(x: 3, y: 1))
        
        let intersectionPoint = CGPoint(x: 2, y: 2)
        let calculatedIntersectionPoint = mathHelper.intersection(of: line1, and: line2)
        XCTAssertNotNil(calculatedIntersectionPoint)
        XCTAssertEqual(calculatedIntersectionPoint!, intersectionPoint)
    }
    
    // MARK: calculateClockwiseRatio
    
    func test_calculateClockwiseRatio_clockwise() {
        let point1 = CGPoint(x: 3, y: 3)
        let point2 = CGPoint(x: 6, y: 0)
        
        XCTAssertGreaterThan(mathHelper.calculateClockwiseRatio(of: point1, and: point2), 0)
    }
    
    func test_calculateClockwiseRatio_counterClockwise() {
        let point1 = CGPoint(x: 6, y: 0)
        let point2 = CGPoint(x: 3, y: 3)
        
        XCTAssertLessThan(mathHelper.calculateClockwiseRatio(of: point1, and: point2), 0)
    }
    
    func test_calculateClockwiseRatio_inLine() {
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 3, y: 0)
        
        XCTAssertEqual(mathHelper.calculateClockwiseRatio(of: point1, and: point2), 0)
    }
    
    // MARK: determinePointsRelation
    
    func test_determinePointsRelation_clockwise() {
        let point1 = CGPoint(x: 3, y: 3)
        let point2 = CGPoint(x: 6, y: 0)
        
        let ratio = mathHelper.calculateClockwiseRatio(of: point1, and: point2)
        XCTAssertEqual(mathHelper.determinePointsRelation(point1: point1, point2: point2), PointsRelation.clockwise(ratio))
    }
    
    func test_determinePointsRelation_counterClockwise() {
        let point1 = CGPoint(x: 6, y: 0)
        let point2 = CGPoint(x: 3, y: 3)
        
        let ratio = mathHelper.calculateClockwiseRatio(of: point1, and: point2)
        XCTAssertEqual(mathHelper.determinePointsRelation(point1: point1, point2: point2), PointsRelation.counterClockwise(ratio))
    }
    
    func test_determinePointsRelation_inLine() {
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 3, y: 0)
        
        XCTAssertEqual(mathHelper.determinePointsRelation(point1: point1, point2: point2), PointsRelation.inLine)
    }
    
    // MARK: solveQuadraticEquasion
    
    func test_solveQuadraticEquasion_noSolutionOnReal() {
        let a: CGFloat = 1
        let b: CGFloat = -4
        let c: CGFloat = 10
        
        let solution = QuadraticEquationSolution.noSolution
        let calculatedSolution = mathHelper.solveQuadraticEquasion(A: a, B: b, C: c)
        XCTAssertEqual(calculatedSolution, solution)
    }
    
    func test_solveQuadraticEquasion_oneSolution() {
        let a: CGFloat = 1
        let b: CGFloat = 4
        let c: CGFloat = 4
        
        let solution = QuadraticEquationSolution.oneSolution(-2)
        let calculatedSolution = mathHelper.solveQuadraticEquasion(A: a, B: b, C: c)
        XCTAssertEqual(calculatedSolution, solution)
    }
    
    func test_solveQuadraticEquasion_twoSolutions() {
        let a: CGFloat = 1
        let b: CGFloat = -3
        let c: CGFloat = -4
        
        let solution = QuadraticEquationSolution.twoSolutions(-1, 4)
        let calculatedSolution = mathHelper.solveQuadraticEquasion(A: a, B: b, C: c)
        XCTAssertEqual(calculatedSolution, solution)
    }
}
