import UIKit

protocol PlanarFaceFinderView: class {
    var presenter: PlanarFaceFinderPresenterInput? { get set }
    
    func clearCanvas()
    func drawCircle(at point: CGPoint)
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint)
    func fillAreaEnclosedBy(points: [CGPoint])
}

final class PlanarFaceFinderViewController: UIViewController {
    var presenter: PlanarFaceFinderPresenterInput?
    
    private var canvas: UIImageView?
    private var clearCanvasButton: UIButton?
    
    private let strokeColor = UIColor(red: 0.35, green: 0.51, blue: 0.55, alpha: 1)
    private let fillColor = UIColor(red: 0.8, green: 0.89, blue: 0.95, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeViews()
        localizeViews()
    }
    
    private func customizeViews() {
        view.tintColor = .blue
        
        createCanvas()
        createClearButton()
    }
    
    private func createCanvas() {
        let canvas = UIImageView()
        canvas.backgroundColor = .white
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
    
    private func createClearButton() {
        let clearCanvasButton = UIButton()
        clearCanvasButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearCanvasButton)
        NSLayoutConstraint.activate([
            clearCanvasButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearCanvasButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
            ])
        clearCanvasButton.setTitleColor(.blue, for: .normal)
        clearCanvasButton.addTarget(self,
                                    action: #selector(PlanarFaceFinderViewController.clearCanvasButtonTouchUpInside),
                                    for: .touchUpInside)
        self.clearCanvasButton = clearCanvasButton
    }
    
    private func localizeViews() {
        clearCanvasButton?.setTitle(NSLocalizedString("planar_face_finder.clear_button_text", comment: ""), for: .normal)
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
    
    @objc private func clearCanvasButtonTouchUpInside() {
        presenter?.clearCanvasButtonTouchUpInside()
    }
}

extension PlanarFaceFinderViewController: PlanarFaceFinderView {
    func clearCanvas() {
        canvas?.layer.sublayers?.filter({ $0 is CAShapeLayer }).forEach({ $0.removeFromSuperlayer() })
        canvas?.image = nil
    }

    func drawCircle(at point: CGPoint) {
        let bezierPath = UIBezierPath(arcCenter: point, radius: 5, startAngle: 0, endAngle: 360, clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.blue.cgColor
        canvas?.layer.addSublayer(shapeLayer)
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
