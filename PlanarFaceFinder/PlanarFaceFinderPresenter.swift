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
    private var calculatedFaces = [Set<Point>]()
    
    private var startPoint: Point?
    private var endPoint: Point?
    
    private func draw() {
        view?.clearCanvas()
        
        calculatedFaces.forEach { points in
            let center = Point(x: (points.reduce(0) { $0 + $1.x }) / CGFloat(points.count), y: (points.reduce(0) { $0 + $1.y }) / CGFloat(points.count))
            let orderedPoints = mathHelper.orderPointsClockwiseDirection(points: Array(points), from: center)
            view?.fillAreaEnclosedBy(points: orderedPoints.map({ CGPoint(x: $0.x, y: $0.y )}))
        }
        
        calculatedLineSegments.forEach { lineSegment in
            view?.drawLine(from: CGPoint(from: lineSegment.startPoint), to: CGPoint(from: lineSegment.endPoint))
        }
        calculatedVertices.forEach { vertice in
            view?.drawCircle(at: CGPoint(from: vertice), radius: 4, color: .blue)
        }
        calculatedTVertices.forEach { vertice in
            let color: UIColor = vertice.tag == nil ? .red : .yellow
            view?.drawCircle(at: CGPoint(from: vertice), radius: 2, color: color)
        }
    }
    
    private func addNewLineSegment(_ lineSegment: LineSegment) {
        calculatedVertices.insert(lineSegment.startPoint)
        calculatedVertices.insert(lineSegment.endPoint)
        
        var intersects = false
        calculatedLineSegments.forEach { currentLineSegment in
            if let intersection = mathHelper.intersection(of: currentLineSegment, and: lineSegment), !calculatedVertices.contains(intersection) {
                intersects = true
                
                calculatedVertices.remove(lineSegment.startPoint)
                calculatedVertices.remove(lineSegment.endPoint)
                calculatedVertices.remove(currentLineSegment.startPoint)
                calculatedVertices.remove(currentLineSegment.endPoint)
                
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
        var calculatedTVertices = Set<Point>(minimumCapacity: calculatedLineSegments.count * 2)
        
        let firstModifier: CGFloat = 1/3
        let secondModifier: CGFloat = 2/3
        calculatedLineSegments.forEach { lineSegment in
            let x1: CGFloat = lineSegment.startPoint.x + firstModifier * (lineSegment.endPoint.x - lineSegment.startPoint.x)
            let y1: CGFloat = lineSegment.startPoint.y + firstModifier * (lineSegment.endPoint.y - lineSegment.startPoint.y)
            
            let x2: CGFloat = lineSegment.startPoint.x + secondModifier * (lineSegment.endPoint.x - lineSegment.startPoint.x)
            let y2: CGFloat = lineSegment.startPoint.y + secondModifier * (lineSegment.endPoint.y - lineSegment.startPoint.y)
            
            calculatedTVertices.insert(Point(x: x1, y: y1, lineSegment: lineSegment))
            calculatedTVertices.insert(Point(x: x2, y: y2, lineSegment: lineSegment))
        }
        
        return calculatedTVertices
    }
    
    private func findFaces() {
        calculatedFaces.removeAll()
        
        var tag = 1
        calculatedVertices.forEach { originalVertex in
            calculatedLineSegments.filter({ $0.startPoint == originalVertex || $0.endPoint == originalVertex }).forEach({ selectedLineSegment in
                var possibleFace = Set<Point>()
                possibleFace.insert(originalVertex)
                
                if var nextVertex = findNextVertex(selectedLineSegment: selectedLineSegment, selectedVertex: originalVertex, tag: tag) {
                    possibleFace.insert(nextVertex)
                    while nextVertex != originalVertex {
                        if let possibleNextVertex = findNextVertex(selectedLineSegment: nextVertex.lineSegment!, selectedVertex: nextVertex, tag: tag) {
                            possibleFace.insert(nextVertex)
                            nextVertex = possibleNextVertex
                        } else {
                            break
                        }
                    }
                    
                    if nextVertex == originalVertex {
                        calculatedFaces.append(possibleFace)
                    }
                }
                tag += 1
                // DEBUG
                // print("possibleFace: \(possibleFace)")
            })
        }
        // DEBUG
        // print("Found faces: \(calculatedFaces)")
    }
    
    private func findNextVertex(selectedLineSegment: LineSegment, selectedVertex: Point, tag: Int) -> Point? {
        let closestTVertex = findClosestTVertex(from: calculatedTVertices, for: selectedVertex, on: selectedLineSegment)
        
        if closestTVertex.tag != nil {
            return nil
        }
        
        closestTVertex.tag = tag
        let closestTVertexDistance = mathHelper.calculateDistanceBetween(point1: selectedVertex, point2: closestTVertex)
        
        let relatedLineSegments = calculatedLineSegments.filter({ ($0.startPoint == selectedVertex || $0.endPoint == selectedVertex) })
        if relatedLineSegments.filter({ $0 != selectedLineSegment }).isEmpty {
            return nil
        }
        
        let circleToSwipe = Circle(center: selectedVertex, radius: closestTVertexDistance)
        
        let closestClockwiseIntersectionPoint = findClosestClockwiseIntersectionPoint(to: closestTVertex, on: relatedLineSegments, with: circleToSwipe)
        guard let nextLineSegment = closestClockwiseIntersectionPoint?.lineSegment else {
            return nil
        }
        let nextVertex = nextLineSegment.startPoint == selectedVertex ? nextLineSegment.endPoint : nextLineSegment.startPoint
        
        nextVertex.lineSegment = nextLineSegment
        return nextVertex
    }
    
    func findClosestTVertex(from tVertices: Set<Point>, for vertex: Point, on edge: LineSegment) -> Point {
        return tVertices.filter({ edge == $0.lineSegment! }).min(by: { p1, p2 in
            let p1DistanceFromVertice = mathHelper.calculateDistanceBetween(point1: vertex, point2: p1)
            let p2DistanceFromVertice = mathHelper.calculateDistanceBetween(point1: vertex, point2: p2)
            return p1DistanceFromVertice < p2DistanceFromVertice
        })!
    }
    
    func findClosestClockwiseIntersectionPoint(to vertex: Point, on lineSegments: Set<LineSegment>, with circle: Circle) -> Point? {
        var intersectionPoints = Set<Point>()
        lineSegments.forEach({ lineSegment in
            if let intersection = intersectionPoint(lineSegment: lineSegment, circle: circle) {
                intersection.lineSegment = lineSegment
                intersectionPoints.insert(intersection)
            }
        })
        
        intersectionPoints.insert(vertex)
        return mathHelper.chooseClosestClockwisePoint(to: vertex, from: Array(intersectionPoints), with: circle.center)
    }
    
    private func intersectionPoint(lineSegment: LineSegment, circle: Circle) -> Point? {
        switch mathHelper.intersection(of: lineSegment, and: circle) {
        case .oneIntersection(let point):
            return point
        case .noIntersection:
            return nil
        case .twoIntersections(_, _):
            fatalError("Impossible.")
        }
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
        findFaces()
        draw()
        
        self.startPoint = nil
        self.endPoint = nil
    }
    
    func clearCanvasButtonTouchUpInside() {
        calculatedVertices.removeAll()
        calculatedTVertices.removeAll()
        calculatedLineSegments.removeAll()
        calculatedFaces.removeAll()
        view?.clearCanvas()
    }
}
