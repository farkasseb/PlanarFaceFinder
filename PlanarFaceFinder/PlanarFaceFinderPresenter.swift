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
    private var lineSegments = [LineSegment]()
    
    private var calculatedVertices = Set<CGPoint>()
    private var calculatedLineSegments = [LineSegment]()
    
    private var startPoint: CGPoint?
    private var endPoint: CGPoint?
    
    private func drawLineSegments() {
        view?.clearCanvas()
        
        calculateVerticesAndEdges()
        calculatedVertices.forEach { vertice in
            view?.drawCircle(at: vertice)
        }
        calculatedLineSegments.forEach { (startPoint, endPoint) in
            view?.drawLine(from: startPoint, to: endPoint)
        }
    }
    
    private func calculateVerticesAndEdges() {
        calculatedVertices.removeAll()
        calculatedLineSegments.removeAll()
        
        lineSegments.forEach { (startPoint, endPoint) in
            calculatedVertices.insert(startPoint)
            calculatedVertices.insert(endPoint)
        }
        
        var tempLineSegments = lineSegments
        while !tempLineSegments.isEmpty {
            let firstLineSegment = tempLineSegments.removeFirst()
            calculatedLineSegments.append(firstLineSegment)
            
            tempLineSegments.forEach { (startPoint, endPoint) in
                if let intersection = mathHelper.intersection(of: (startPoint, endPoint),
                                                              and: (firstLineSegment.p1, firstLineSegment.p2)) {
                    calculatedVertices.insert(intersection)
                    
                    _ = calculatedLineSegments.removeLast() // instead of the original segment we have 4 segments
                    calculatedLineSegments.append((p1: intersection, p2: firstLineSegment.p1))
                    calculatedLineSegments.append((p1: intersection, p2: firstLineSegment.p2))
                    calculatedLineSegments.append((p1: intersection, p2: startPoint))
                    calculatedLineSegments.append((p1: intersection, p2: endPoint))
                }
            }
        }
    }
}

extension PlanarFaceFinderPresenter: PlanarFaceFinderPresenterInput {
    func drawingStarted(from startPoint: CGPoint) {
        self.startPoint = startPoint
    }
    
    func drawingMoved(to endPoint: CGPoint) {
        self.endPoint = endPoint
        
        if let startPoint = startPoint {
            drawLineSegments()
            view?.drawLine(from: startPoint, to: endPoint)
        }
    }
    
    func drawingFinished() {
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        lineSegments.append((startPoint, endPoint))
        drawLineSegments()
        
        self.startPoint = nil
        self.endPoint = nil
    }
    
    func clearCanvasButtonTouchUpInside() {
        lineSegments.removeAll()
        view?.clearCanvas()
    }
}
