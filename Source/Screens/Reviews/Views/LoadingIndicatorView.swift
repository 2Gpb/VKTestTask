import UIKit

final class LoadingIndicatorView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let size = 32.0
        static let lineWidth = 3.6
        static let strokeEnd = 0.75
        static let animationDuration: CFTimeInterval = 1
        static let color: UIColor = .systemBlue
        static let rotationKey = "transform.rotation"
    }
    
    // MARK: - Properties
    
    private let indicatorLayer = CAShapeLayer()
    private let rotation = CABasicAnimation(keyPath: Constants.rotationKey)
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: Constants.size, height: Constants.size)
    }
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: Constants.size, height: Constants.size)))
        setUp()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorLayer.frame = bounds
        indicatorLayer.path = circularPath().cgPath
    }
    
}
    
// MARK: - Internal

extension LoadingIndicatorView {
    
    func startAnimating() {
        guard indicatorLayer.animation(forKey: Constants.rotationKey) == nil else { return }
        isHidden = false
        
        rotation.fromValue = 0
        rotation.toValue = 2 * CGFloat.pi
        rotation.duration = Constants.animationDuration
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        indicatorLayer.add(rotation, forKey: Constants.rotationKey)
    }
    
    func stopAnimating() {
        isHidden = true
        indicatorLayer.removeAllAnimations()
    }
    
}
    
// MARK: - Private
    
private extension LoadingIndicatorView {
    
    private func setUp() {
        isHidden = true
        
        indicatorLayer.strokeColor = Constants.color.cgColor
        indicatorLayer.fillColor = UIColor.clear.cgColor
        indicatorLayer.lineWidth = Constants.lineWidth
        indicatorLayer.lineCap = .round
        indicatorLayer.strokeStart = .zero
        indicatorLayer.strokeEnd = Constants.strokeEnd
        layer.addSublayer(indicatorLayer)
    }
    
    private func circularPath() -> UIBezierPath {
        let radius = (min(bounds.width, bounds.height) - Constants.lineWidth) / 2
        return UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
    }
    
}
