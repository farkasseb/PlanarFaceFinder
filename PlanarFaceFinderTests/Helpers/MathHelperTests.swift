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
    
}
