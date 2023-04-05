//
//  SliceLayer.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 05/06/22.
//

import Foundation
import UIKit
public class BaseLayer:CAShapeLayer,CAAnimationDelegate
{
    var animations:[CAAnimation] = [];
    public var keys:[String] = []
    public func animationDidStart(_ anim: CAAnimation) {
        animations.append(anim)
    }
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animations.removeAll(where: {$0 == anim})
        if animations.count == 0
        {
            self.removeAllAnimations()
            keys.removeAll()
        }
    }
    
    public func AddAnimation(newValue:CGFloat,oldValue:CGFloat,for key:String,duration:CFTimeInterval,
                             timingName:CAMediaTimingFunctionName = CAMediaTimingFunctionName.linear,isDamping:Bool = false)
    {
        var animation:CABasicAnimation?
        if(isDamping)
        {
            animation = CASpringAnimation(keyPath:  key)
        }
        else
        {
            animation = CABasicAnimation(keyPath:  key)
        }
        animation!.fromValue = oldValue;
        animation!.toValue = newValue;
        animation!.isRemovedOnCompletion = false;
        animation!.fillMode = CAMediaTimingFillMode.forwards
        animation!.timingFunction = CAMediaTimingFunction(name: timingName)
        animation!.duration = duration;
        animation!.delegate = self
        self.add(animation!, forKey:  key)
        if(!keys.contains(where: {$0 == key}))
        {
            keys.append(key);
        }
        self.setValue(newValue, forKey: key)
    }
}
public class WholeCircleLayer:BaseLayer
{
    public var center:CGPoint = CGPoint();
    public var radius:CGFloat = 0;
    public var startAngle:CGFloat = 0;
}
public class SliceLayer:BaseLayer
{
    @objc dynamic var radius:CGFloat = 0;
    @objc dynamic var clipRadius:CGFloat = 0;
    @objc dynamic var startAngle:CGFloat = 0;
    public var angleToStartAnimation:CGFloat = 0;
    var sliceFillColor:CGColor?
    @objc dynamic var endAngle:CGFloat = 0;
    var _isSelected:Bool = false;
    var isSelected:Bool
    {
        get
        {
            return _isSelected;
        }
        set
        {
            _isSelected = newValue;
            if _isSelected
            {
                self.fillColor = UIColor.clear.cgColor
            }
            else
            {
                self.fillColor = self.sliceFillColor ?? UIColor.systemPink.cgColor
            }
        }
    };
    var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor.red.cgColor,
            UIColor.blue.cgColor
        ]
        return gradient
    }()
    public var center:CGPoint = CGPoint();
    var finalPath:CGPath?
    
    public override func display() {
        super.display()
        var interPolatedStartAngle = self.presentation()?.startAngle ?? self.startAngle
        var interPolatedEndAngle = self.presentation()?.endAngle ?? self.endAngle
        var interpolatedRadius = self.presentation()?.radius ?? self.radius
        var clipRadius = self.presentation()?.clipRadius ?? self.clipRadius
        if(interpolatedRadius == 0)
        {
            interpolatedRadius = self.radius;
        }
        if(interPolatedStartAngle == 0)
        {
            interPolatedStartAngle = self.startAngle;
        }
        if(interPolatedEndAngle == 0)
        {
            interPolatedEndAngle = self.endAngle;
        }
        if(clipRadius == 0)
        {
            clipRadius = self.clipRadius;
        }
        //print("interpolated start \(interPolatedStartAngle) end \(interPolatedEndAngle) Final start \(self.startAngle) end \(self.endAngle)")
        let slicePath:CGMutablePath = CGMutablePath()
        //slicePath.move(to: center)
        slicePath.addArc(center: center, radius: interpolatedRadius, startAngle: interPolatedStartAngle, endAngle: interPolatedEndAngle, clockwise: false)
        slicePath.addArc(center: center, radius: clipRadius, startAngle: interPolatedEndAngle, endAngle: interPolatedStartAngle, clockwise: true)
        slicePath.closeSubpath()
        self.path = slicePath;
    }
    
    public override class func needsDisplay(forKey key: String) -> Bool {
        if (key == #keyPath(SliceLayer.startAngle) || key == #keyPath(SliceLayer.endAngle) || key == #keyPath(SliceLayer.radius))
        {
            return true;
        }
        else
        {
            return super.needsDisplay(forKey: key)
        }
    }
    var smallesttSide:CGFloat
    {
        get
        {
            return (self.frame.width > self.frame.height) ? self.frame.height:self.frame.size.width
        }
    }
    public override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        super.animationDidStop(anim, finished: flag)
        if(_isSelected)
        {
            self.fillColor = UIColor.clear.cgColor
            let gradToApply = gradient;
            gradToApply.frame = self.bounds
            let startPoint = self.clipRadius/smallesttSide
            let end = self.radius/smallesttSide
            let pointOfGradientChange = startPoint+((end-startPoint)/2)
            gradToApply.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradToApply.endPoint = CGPoint(x: 1, y: 1)
            gradToApply.colors = [
                UIColor.white.cgColor,
                (self.sliceFillColor ?? UIColor.red.cgColor)
            ]
            gradToApply.locations = [NSNumber(value: pointOfGradientChange)];
            var maskLayer:CAShapeLayer?
            if let layer = gradToApply.mask, let castLayer = layer as? CAShapeLayer
            {
                maskLayer = castLayer
            }
            else
            {
                maskLayer = CAShapeLayer();
                gradToApply.mask = maskLayer;
            }
            let slicePath:CGMutablePath = CGMutablePath()
            
            slicePath.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            slicePath.addArc(center: center, radius: clipRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
            slicePath.closeSubpath()
            maskLayer!.path = slicePath;
            self.addSublayer(gradToApply)
        }
        else
        {
            self.fillColor = self.sliceFillColor ?? UIColor.systemPink.cgColor
            gradient.removeFromSuperlayer()
        }
    }
}
