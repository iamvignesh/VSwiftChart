//
//  LegendCell.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 12/02/23.
//

import Foundation
import UIKit
class LegendCell:UICollectionViewCell
{
    var colorView:UIView?
    var titleLabel:UILabel?
    static let font:UIFont = UIFont.systemFont(ofSize: 12, weight: .medium);
    var color:UIColor?
    {
        didSet
        {
            colorView?.backgroundColor = color ?? UIColor.red
        }
    }
    var title:String?
    {
        didSet
        {
            titleLabel?.text = title ?? "";
        }
    }
    
    var clrWidth:CGFloat
    {
        clrHeight;
    }
    var clrHeight:CGFloat
    {
        self.frame.size.height-VerticalPadding
    }
    var lblWidth:CGFloat
    {
        self.frame.width-clrWidth;
    }
    var VerticalPadding:CGFloat
    {
        0.1*bounds.height
    }
    var clrRect:CGRect
    {
        CGRect(x: 0, y: VerticalPadding/2, width: clrWidth, height: clrHeight);
    }
    var lblRect:CGRect
    {
        CGRect(x: clrRect.maxX+6, y: VerticalPadding/2, width: lblWidth-6, height: self.frame.size.height-VerticalPadding)
    }
    func UIInitialize()
    {
        colorView = UIView(frame: clrRect);
        colorView?.layer.cornerRadius = clrRect.size.height/4
        titleLabel = UILabel(frame: lblRect);
        titleLabel?.textColor = UIColor.white
        titleLabel?.font = LegendCell.font;
        titleLabel?.textAlignment = .left
        self.contentView.addSubview(colorView!)
        self.contentView.addSubview(titleLabel!)
    }
    func reSize()
    {
        colorView?.frame = clrRect;
        titleLabel?.frame = lblRect;
        colorView?.backgroundColor = color ?? UIColor.red;
        titleLabel?.text = title ?? ""
    }
    var initialWidth:CGFloat = 0;
    var initialHeight:CGFloat = 0;
    var initialized:Bool = false;
    open override func layoutSubviews() {
        if(!initialized)
        {
            initialized = true;
            UIInitialize();
        }
        let width = self.frame.width;
        let height = self.frame.height;
        if(width != initialWidth && height != initialWidth)
        {
            initialWidth = width;
            initialHeight = height;
            reSize();
        }
    }
}
