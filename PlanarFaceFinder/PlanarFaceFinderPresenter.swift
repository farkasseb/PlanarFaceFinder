import UIKit

protocol PlanarFaceFinderPresenterInput: class {
    var view: PlanarFaceFinderView? { get set }
    
    func drawingStarted(from startPoint: CGPoint)
    func drawingMoved(to endPoint: CGPoint)
    func drawingFinished()
}

final class PlanarFaceFinderPresenter {
    weak var view: PlanarFaceFinderView?
    
    private var lineSegments = [LineSegment]()
    
    private var startPoint: CGPoint?
    private var endPoint: CGPoint?
    
    private func drawLineSegments() {
        view?.clearCanvas()
        lineSegments.forEach { startPoint, endPoint in
            view?.drawLine(from: startPoint, to: endPoint)
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
}
