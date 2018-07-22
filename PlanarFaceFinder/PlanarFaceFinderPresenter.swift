import UIKit

protocol PlanarFaceFinderPresenterInput: class {
    var view: PlanarFaceFinderView? { get set }
    
    func drawingStarted(from startPoint: CGPoint)
    func drawingMoved(to endPoint: CGPoint)
    func drawingFinished()
    
    func clearCanvasButtonTouchUpInside()
}

final class PlanarFaceFinderPresenter {
    weak var view: PlanarFaceFinderView?
    
    private let mathHelper: MathHelper = MathHelperImplementation.sharedInstance
    
    private var calculatedVertices = Set<Point>()
    private var calculatedTVertices = Set<Point>()
    private var calculatedLineSegments = Set<LineSegment>()
    
    private var startPoint: Point?
    private var endPoint: Point?
    
    private func draw() {
        view?.clearCanvas()
        
        calculatedVertices.forEach { vertice in
            view?.drawCircle(at: CGPoint(from: vertice), with: .blue)
        }
        calculatedLineSegments.forEach { lineSegment in
            view?.drawLine(from: CGPoint(from: lineSegment.startPoint), to: CGPoint(from: lineSegment.endPoint))
        }
        calculatedTVertices.forEach { vertice in
            view?.drawCircle(at: CGPoint(from: vertice), with: .yellow)
        }
    }
    
    private func addNewLineSegment(_ lineSegment: LineSegment) {
        calculatedVertices.insert(lineSegment.startPoint)
        calculatedVertices.insert(lineSegment.endPoint)
        
        var intersects = false
        calculatedLineSegments.forEach { currentLineSegment in
            if let intersection = mathHelper.intersection(of: currentLineSegment, and: lineSegment), !calculatedVertices.contains(intersection) {
                intersects = true
                calculatedVertices.insert(intersection)
                
                calculatedLineSegments.remove(currentLineSegment)
                let newLineSegments = [
                    LineSegment(startPoint: intersection, endPoint: lineSegment.startPoint),
                    LineSegment(startPoint: intersection, endPoint: lineSegment.endPoint),
                    LineSegment(startPoint: intersection, endPoint: currentLineSegment.startPoint),
                    LineSegment(startPoint: intersection, endPoint: currentLineSegment.endPoint)
                ]
                newLineSegments.forEach({ addNewLineSegment($0) })
            }
        }
        
        if !calculatedLineSegments.contains(lineSegment) && !intersects {
            calculatedLineSegments.insert(lineSegment)
        }
    }
    
    private func calculateTVertices() -> Set<Point> {
        var calculatedTVertices = Set<Point>()
        
        let firstModifier: CGFloat = 1/3
        let secondModifier: CGFloat = 2/3
        calculatedLineSegments.forEach { lineSegment in
            let x1: CGFloat = lineSegment.startPoint.x + firstModifier * (lineSegment.endPoint.x - lineSegment.startPoint.x)
            let y1: CGFloat = lineSegment.startPoint.y + firstModifier * (lineSegment.endPoint.y - lineSegment.startPoint.y)
            
            let x2: CGFloat = lineSegment.startPoint.x + secondModifier * (lineSegment.endPoint.x - lineSegment.startPoint.x)
            let y2: CGFloat = lineSegment.startPoint.y + secondModifier * (lineSegment.endPoint.y - lineSegment.startPoint.y)
            
            calculatedTVertices.insert(Point(x: x1, y: y1))
            calculatedTVertices.insert(Point(x: x2, y: y2))
        }
        
        return calculatedTVertices
    }
}

extension PlanarFaceFinderPresenter: PlanarFaceFinderPresenterInput {
    func drawingStarted(from startPoint: CGPoint) {
        self.startPoint = Point(from: startPoint)
    }
    
    func drawingMoved(to endPoint: CGPoint) {
        self.endPoint = Point(from: endPoint)
        
        if let startPoint = startPoint {
            draw()
            view?.drawLine(from: CGPoint(from: startPoint), to: endPoint)
        }
    }
    
    func drawingFinished() {
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        addNewLineSegment(LineSegment(startPoint: startPoint, endPoint: endPoint))
        calculatedTVertices = calculateTVertices()
        draw()
        
        self.startPoint = nil
        self.endPoint = nil
    }
    
    func clearCanvasButtonTouchUpInside() {
        calculatedVertices.removeAll()
        calculatedTVertices.removeAll()
        calculatedLineSegments.removeAll()
        view?.clearCanvas()
    }
}
