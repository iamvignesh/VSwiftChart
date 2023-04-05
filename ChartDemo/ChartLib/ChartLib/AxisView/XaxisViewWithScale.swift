//
//  XaxisViewWithScale.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 30/03/23.
//

import Foundation
import UIKit
import CoreText

class XaxisViewWithScale:BasicXaxisView
{
    public var minValue:CGFloat = 0;
    public var maxValue:CGFloat = 0;
    public var xAxisUnit:CGFloat = 0;
    public var interval:CGFloat = 5;
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(min:CGFloat,max:CGFloat,frame: CGRect,yaxisWidth:CGFloat,unit:CGFloat)
    {
        super.init(frame: frame)
        self.yAxisWidth = yaxisWidth;
        self.minValue = min
        self.maxValue = max
        self.xAxisUnit = unit
        self.clipsToBounds = false;
    }
    
    override func reloadData(completion:@escaping (()->Void)={
        
    }) {
        setNeedsDisplay()
    }
    var width:CGFloat
    {
        get
        {
            return self.frame.width;
        }
    }
    override func draw(_ rect: CGRect) {
        if(xAxisUnit != 0 )
        {
            if let ctx = UIGraphicsGetCurrentContext()
            {
                let yTopOffset:CGFloat = 6;
                var i = 1;
                while((CGFloat (i) * interval)*xAxisUnit <= width)
                {
                    let font = UIFont.systemFont(ofSize: 12, weight: .light)
                    let fontName = font.fontName as NSString
                    let value = (CGFloat (i) * interval)
                    let str = String(Int(minValue + value))
                    
                    if let cgFont = CGFont(fontName)
                    {
                        ctx.setFont(cgFont)
                    }
                    let uiText = NSAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
                    let textWidth = uiText.width(withConstrainedHeight: parentHeight-yTopOffset)
                    let x = (CGFloat (i) * interval)*xAxisUnit;
                    uiText.draw(at: CGPoint(x: x-(textWidth/2), y: yTopOffset));
                    i += 1;
                }
            }
        }
    }
}
