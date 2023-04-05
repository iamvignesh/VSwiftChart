//
//  XAxisView.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 29/04/22.
//

import Foundation
import UIKit
import CoreText
class XAxisView:BasicXaxisView
{
    init(yaxisWidth:CGFloat,frame:CGRect)
    {
        super.init(frame: frame)
        self.yAxisWidth = yaxisWidth;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func reloadData(completion:@escaping (()->Void)={
        
    }) {
        setNeedsDisplay()
    }
    override func draw(_ rect: CGRect) {
        if let source = dataSource,let ctx = UIGraphicsGetCurrentContext()
        {
            let yTopOffset:CGFloat = 6;
            var strings:Array<String> = Array<String>();
            let elementsCount = source.numberOfXAxisElements()
            for i in 0...elementsCount-1
            {
                strings.append(source.XAxisStringAt(index: i));
            }
            let widthSpace = parentWidth/CGFloat(elementsCount)
            var curX:CGFloat = self.yAxisWidth ?? 0;
            for str in strings
            {
                let font = UIFont.systemFont(ofSize: 12, weight: .light)
                let fontName = font.fontName as NSString
                if let cgFont = CGFont(fontName)
                {
                    ctx.setFont(cgFont)
                    let uiText = NSAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
                    let textWidth = uiText.width(withConstrainedHeight: parentHeight-yTopOffset)
                    uiText.draw(at: CGPoint(x: curX-(textWidth/2), y: yTopOffset));
                    curX += widthSpace;
                }
            }
        }
    }
}
