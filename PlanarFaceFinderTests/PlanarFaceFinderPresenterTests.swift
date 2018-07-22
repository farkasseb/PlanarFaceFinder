import XCTest
@testable import PlanarFaceFinder

class PlanarFaceFinderTests: XCTestCase {
    
    var presenter: PlanarFaceFinderPresenter!
    
    override func setUp() {
        super.setUp()
        
        presenter = PlanarFaceFinderPresenter()
    }
    
    func test_findClosestTVertex_example() {
        let startPoint = Point(x: 0, y: 0)
        let lineSegment = LineSegment(startPoint: startPoint, endPoint: Point(x: 3, y: 0))
        
        let closestTVertex = Point(x: 1, y: 0, lineSegment: lineSegment)
        let otherTVertex = Point(x: 2, y: 0, lineSegment: lineSegment)
        
        let tVertices = Set<Point>(arrayLiteral: closestTVertex, otherTVertex)
        
        XCTAssertEqual(presenter.findClosestTVertex(from: tVertices, for: startPoint, on: lineSegment), closestTVertex)
    }
    
    func test_findClosestClockwiseIntersectionPoint_noOtherLineSegment() {
        let originalVertex = Point(x: 0, y: 0)
        let closestTVertex = Point(x: 1, y: 0)
        let circle = Circle(center: originalVertex, radius: 1)
        
        let closestClockwiseIntersectionPoint = presenter.findClosestClockwiseIntersectionPoint(to: closestTVertex, on: Set<LineSegment>(), with: circle)
        XCTAssertNil(closestClockwiseIntersectionPoint)
    }
    
    func test_findClosestClockwiseIntersectionPoint_onlyOneIntersection() {
        let originalVertex = Point(x: 0, y: 0)
        
        let lineSegment = LineSegment(startPoint: originalVertex, endPoint: Point(x: 3, y: 0))
        
        let closestTVertex = Point(x: 1, y: 1)
        let circle = Circle(center: originalVertex, radius: 1)
        
        let closestClockwiseIntersectionPoint = presenter.findClosestClockwiseIntersectionPoint(to: closestTVertex, on: Set<LineSegment>(arrayLiteral: lineSegment), with: circle)
        XCTAssertEqual(closestClockwiseIntersectionPoint, Point(x: 1, y: 0))
    }
    
    func test_findClosestClockwiseIntersectionPoint_twoIntersections() {
        let originalVertex = Point(x: 0, y: 0)
        
        let lineSegment1 = LineSegment(startPoint: originalVertex, endPoint: Point(x: 3, y: 0))
        let lineSegment2 = LineSegment(startPoint: originalVertex, endPoint: Point(x: -3, y: 0))
        
        let closestTVertex = Point(x: 1, y: 1)
        let circle = Circle(center: originalVertex, radius: 1)
        
        let closestClockwiseIntersectionPoint = presenter.findClosestClockwiseIntersectionPoint(to: closestTVertex, on: Set<LineSegment>(arrayLiteral: lineSegment1, lineSegment2), with: circle)
        XCTAssertEqual(closestClockwiseIntersectionPoint, Point(x: -1, y: 0))
    }
    
}
