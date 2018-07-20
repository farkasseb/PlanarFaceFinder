import UIKit

typealias Line = (p1: CGPoint, p2: CGPoint)

protocol MathHelper {
    func intersectionOfLineSegments(line1: Line, line2: Line) -> CGPoint?
}

final class MathHelperImplementation: MathHelper {
    
    //http://www.cs.swan.ac.uk/~cssimon/line_intersection.html
    func intersectionOfLineSegments(line1: Line, line2: Line) -> CGPoint? {
        // line1: p1: (x1, y1), p2: (x2, y2)
        // line2: p1: (x3, y3), p2: (x4, y4)
        
        // tA = ((y3−y4)(x1−x3) + (x4−x3)(y1−y3)) / ((x4−x3)(y1−y2) − (x1−x2)(y4−y3))
        let tANumerator: CGFloat = ((line2.p1.y - line2.p2.y) * (line1.p1.x - line2.p1.x)) + ((line2.p2.x - line2.p1.x) * (line1.p1.y - line2.p1.y))
        let tADenominator: CGFloat = ((line2.p2.x - line2.p1.x) * (line1.p1.y - line1.p2.y)) - ((line1.p1.x - line1.p2.x) * (line2.p2.y - line2.p1.y))
        guard tADenominator != 0 else {
            return nil
        }
        let tA: CGFloat = tANumerator / tADenominator
        
        // tB = ((y1−y2)(x1−x3) + (x2−x1)(y1−y3)) / ((x4−x3)(y1−y2) − (x1−x2)(y4−y3))
        let tBNumerator: CGFloat = ((line1.p1.y - line1.p2.y) * (line1.p1.x - line2.p1.x)) + ((line1.p2.x - line1.p1.x) * (line1.p1.y - line2.p1.y))
        let tBDenominator: CGFloat = ((line2.p2.x - line2.p1.x) * (line1.p1.y - line1.p2.y)) - ((line1.p1.x - line1.p2.x) * (line2.p2.y - line2.p1.y))
        guard tBDenominator != 0 else {
            return nil
        }
        let tB: CGFloat = tBNumerator / tBDenominator
        
        if tA >= 0 && tA <= 1 && tB >= 0 && tB <= 1 {
            // p1 + t(p2 − p1)
            let x: CGFloat = line1.p1.x + tA * (line1.p2.x - line1.p1.x)
            let y: CGFloat = line1.p1.y + tA * (line1.p2.y - line1.p1.y)
            return CGPoint(x: x, y: y)
        } else {
            return nil
        }
    }
}
