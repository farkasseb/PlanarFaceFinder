import UIKit

protocol PlanarFaceFinderView: class {
    var presenter: PlanarFaceFinderPresenterInput? { get set }
    
    func clearCanvas()
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint)
}

final class PlanarFaceFinderViewController: UIViewController {
    var presenter: PlanarFaceFinderPresenterInput?
    
    private var canvas: UIImageView?
    
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
        canvas?.image = nil
    }
    
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        canvas?.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        context?.move(to: startPoint)
        context?.addLine(to: endPoint)
        
        context?.setLineWidth(3)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setBlendMode(.normal)
        
        context?.strokePath()
        
        canvas?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
