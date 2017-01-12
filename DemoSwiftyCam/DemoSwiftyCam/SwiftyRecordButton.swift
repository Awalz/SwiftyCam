//
//  SwiftyRecordButton.swift
//  SwiftyRecordButton
//
//  Created by Andrew on 2017-01-11.
//  Copyright © 2017 Walzy. All rights reserved.
//

import UIKit

class SwiftyRecordButton: SwiftyCamButton {
    
    private var circleBorder: CALayer!
    private var innerCircle: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawButton()
    }
    
    private func drawButton() {
        self.backgroundColor = UIColor.clear
        
       circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 6.0
        circleBorder.borderColor = UIColor.white.cgColor
        circleBorder.bounds = self.bounds
        circleBorder.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)

    }
    
    public  func growButton() {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue = 1.20
        scale.duration = 0.3
        scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        
        
        innerCircle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        innerCircle.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        innerCircle.backgroundColor = UIColor.red
        innerCircle.layer.cornerRadius = innerCircle.frame.size.width / 2
        innerCircle.clipsToBounds = true
        self.addSubview(innerCircle)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.innerCircle.transform = CGAffineTransform(scaleX: 50.0, y: 50.0)

        }, completion: nil)
        
        circleBorder.add(scale, forKey: "grow")
    }
    
    public func shrinkButton() {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.20
        scale.toValue = 1.0
        scale.duration = 0.3
        scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.innerCircle.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

        }, completion: { (success) in
            self.innerCircle.removeFromSuperview()
            self.innerCircle = nil
        })
        
        circleBorder.add(scale, forKey: "grow")
    }
}
