//
//  ShimmerView.swift
//  UpNews
//
//  Created by Peter on 03.02.2025.
//

import UIKit

final class ShimmerView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Error {
            static let value: String = "init(coder:) has not been implemented"
        }
        
        enum Gradient {
            static let startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
            static let endPoint: CGPoint = CGPoint(x: 1.0, y: 0.3)
            static let locations: [NSNumber] = [0.4, 0.5, 0.6]
            static let colors: [CGColor] = [
                UIColor.lightGray.cgColor,
                UIColor.gray.cgColor,
                UIColor.lightGray.cgColor
            ]
        }
        
        enum Animation {
            static let key: String = "locations"
            static let from: [NSNumber] = [-1.0, -0.5, 0.0]
            static let to: [NSNumber] = [1.0, 1.5, 2.0]
            static let repeatCount: Float = .infinity
            static let duration: TimeInterval = 0.68
        }
        
    }
    
    // MARK: - Private fields
    
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    private let animation = CABasicAnimation(keyPath: Constants.Animation.key)
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError(Constants.Error.value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
}
    
// MARK: - Internal

extension ShimmerView {
    
    func startShimmering() {
        animation.fromValue = Constants.Animation.from
        animation.toValue = Constants.Animation.to
        animation.repeatCount = Constants.Animation.repeatCount
        animation.duration = Constants.Animation.duration
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopShimmering() {
        gradientLayer.removeAllAnimations()
    }
    
}
    
// MARK: - Private

private extension ShimmerView {
    
    func setUpGradient() {
        gradientLayer.startPoint = Constants.Gradient.startPoint
        gradientLayer.endPoint = Constants.Gradient.endPoint
        self.layer.addSublayer(gradientLayer)
        gradientLayer.colors = Constants.Gradient.colors
        gradientLayer.locations = Constants.Gradient.locations
    }
    
}
