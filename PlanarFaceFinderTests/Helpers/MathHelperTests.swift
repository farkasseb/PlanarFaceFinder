import XCTest
@testable import PlanarFaceFinder

class MathHelperTests: XCTestCase {
    
    var mathHelper: MathHelper!
    
    override func setUp() {
        super.setUp()

        mathHelper = MathHelperImplementation()
    }
    
    func test_intersectionOfLineSegments_noIntersection() {
        let line1 = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let line2 = (p1: CGPoint(x: 3, y: 1), p2: CGPoint(x: 5, y: 3))
        
        XCTAssertNil(mathHelper.intersectionOfLineSegments(line1: line1, line2: line2))
    }
    
    func test_intersectionOfLineSegments_intersection() {
        let line1 = (p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 3, y: 3))
        let line2 = (p1: CGPoint(x: 1, y: 3), p2: CGPoint(x: 3, y: 1))
        
        let intersectionPoint = CGPoint(x: 2, y: 2)
        let calculatedIntersectionPoint = mathHelper.intersectionOfLineSegments(line1: line1, line2: line2)
        XCTAssertNotNil(calculatedIntersectionPoint)
        XCTAssertEqual(calculatedIntersectionPoint!, intersectionPoint)
    }
    
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
    
    
    
}
