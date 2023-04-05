//
//  BasicYAxisView.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 15/10/22.
//

import Foundation
import CoreGraphics

class BasicYAxisView:AxisView
{
    var minValue:CGFloat = 0;
    var maxValue:CGFloat = 0;
    var yAxisUnit:CGFloat = 0;
    public var interval:CGFloat = 0;
    
    init(max:CGFloat,min:CGFloat,frame:CGRect) {
        super.init(frame: frame)
        self.minValue = min
        self.maxValue = max;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
