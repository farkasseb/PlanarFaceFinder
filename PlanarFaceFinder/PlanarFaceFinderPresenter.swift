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
    
    private var startPoint: CGPoint?
    private var endPoint: CGPoint?
    
    private func drawLineSegments() {
        view?.clearCanvas()
        lineSegments.forEach { startPoint, endPoint in
            view?.drawLine(from: startPoint, to: endPoint)
        }
        getAllVertices().forEach { vertice in
            view?.drawCircle(at: vertice)
        }
    }
    
    private func getAllVertices() -> Set<CGPoint> {
        var allVertices = Set<CGPoint>()
        
        lineSegments.forEach { (startPoint, endPoint) in
            allVertices.insert(startPoint)
            allVertices.insert(endPoint)
        }
        
        var tempLineSegments = lineSegments
        while !tempLineSegments.isEmpty {
            let firstLineSegment = tempLineSegments.removeFirst()
            tempLineSegments.forEach { (startPoint, endPoint) in
                if let intersection = mathHelper.intersection(of: (startPoint, endPoint), and: (firstLineSegment.p1, firstLineSegment.p2)) {
                    allVertices.insert(intersection)
                }
            }
        }
        
        return allVertices
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
