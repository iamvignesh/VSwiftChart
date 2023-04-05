//
//  BaseView.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 29/04/22.
//

import Foundation
import UIKit
public class BaseView:UIView
{
    var initialWidth:CGFloat = 0;
    var initialHeight:CGFloat = 0;
    var initialized:Bool = false;
    open override func layoutSubviews() {
        if(!initialized)
        {
            initialized = true;
            InitializeUIElements()
        }
        let width = self.frame.width;
        let height = self.frame.height;
        if(width != initialWidth && height != initialWidth)
        {
            initialWidth = width;
            initialHeight = height;
            reloadData();
        }
    }
    func InitializeUIElements()
    {
        
    }
    var parentWidth:CGFloat
    {
        self.frame.width
    }
    var parentHeight:CGFloat
    {
        self.frame.height
    }
    
    public func reloadData(completion:@escaping (()->Void)={
        
    })
    {
        
    }
}
