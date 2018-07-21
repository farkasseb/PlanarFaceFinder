import UIKit

protocol PlanarFaceFinderView: class {
    var presenter: PlanarFaceFinderPresenterInput? { get set }
    
    func clearCanvas()
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint)
    func fillAreaEnclosedBy(points: [CGPoint])
}

final class PlanarFaceFinderViewController: UIViewController {
    var presenter: PlanarFaceFinderPresenterInput?
    
    private var canvas: UIImageView?
    
    private let strokeColor = UIColor(red: 0.35, green: 0.51, blue: 0.55, alpha: 1)
    private let fillColor = UIColor(red: 0.8, green: 0.89, blue: 0.95, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeViews()
    }
    
    private func customizeViews() {
        view.backgroundColor = .white
        
        let canvas = UIImageView()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.canvas = canvas
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            presenter?.drawingStarted(from: touch.location(in: view))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            presenter?.drawingMoved(to: touch.location(in: view))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        presenter?.drawingFinished()
    }
}

extension PlanarFaceFinderViewController: PlanarFaceFinderView {
    func clearCanvas() {
        canvas?.layer.sublayers?.filter({ $0 is CAShapeLayer }).forEach({ $0.removeFromSuperlayer() })
        canvas?.image = nil
    }
    
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        canvas?.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        context?.move(to: startPoint)
        context?.addLine(to: endPoint)
        
        context?.setLineWidth(3)
        context?.setStrokeColor(strokeColor.cgColor)
        context?.setBlendMode(.normal)
        
        context?.strokePath()
        
        canvas?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func fillAreaEnclosedBy(points: [CGPoint]) {
        guard points.count > 3, let firstPoint = points.first else {
            return
        }
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: firstPoint)
        points[1 ..< points.count].forEach { point in
            bezierPath.addLine(to: point)
        }
        bezierPath.addLine(to: firstPoint)
        bezierPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        
        canvas?.layer.addSublayer(shapeLayer)
    }
}
