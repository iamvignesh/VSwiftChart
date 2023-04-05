//
//  YAxisView.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 16/07/22.
//

import Foundation
import UIKit
import CoreText
class YAxisView:BasicYAxisView
{
    override func reloadData(completion:@escaping (()->Void)={
        
    })
    {
        setNeedsDisplay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(min:CGFloat,max:CGFloat,frame: CGRect)
    {
        super.init(max: max, min: min, frame: frame)
        self.clipsToBounds = false;
    }
    
    var height:CGFloat
    {
        get
        {
            return self.bounds.size.height;
        }
    }
    
//    func digits(value:CGFloat)->Int
//    {
//        var dividedVaue:Int = Int(value/10)
//        var digits:Int = value != 0 ? 1 : 0;
//        while(dividedVaue != 0)
//        {
//            dividedVaue = dividedVaue/10
//            digits += 1
//        }
//        return digits
//    }
    override func draw(_ rect: CGRect) {
        if maxValue != 0 && interval != 0
        {
            if let ctx = UIGraphicsGetCurrentContext()
            {
                ctx.setStrokeColor(UIColor.white.cgColor)
                var i = 1;
                while((CGFloat (i) * interval)*yAxisUnit <= height)
                {
                    let value = (CGFloat (i) * interval)
                    let str = String(Int(minValue + value))
                    let font = UIFont.systemFont(ofSize: 12, weight: .light)
                    let fontName = font.fontName as NSString
                    
                    if let cgFont = CGFont(fontName)
                    {
                        ctx.setFont(cgFont)
                        var point = CGPoint(x: 0, y: height - value*yAxisUnit)
                        let uiText = NSAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
                        let height = uiText.height(withConstrainedWidth: parentWidth);
                        point.y = point.y - height/2
                        let width = uiText.width(withConstrainedHeight: height);
                        point.x = parentWidth-width-4;
                        uiText.draw(at: point);
                    }
                    i += 1
                }
            }
            
        }
    }
}
