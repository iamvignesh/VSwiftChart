//
//  AxisBasedChart.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 03/05/22.
//

import Foundation
import UIKit
public class AxisBasedChart:ChartBase
{
    
    var xAxisUnit:Float = 0;
    ///  pixels perUnit of Quantity
    var yAxisUnit:Float = 0;
    let xAxisHeight:CGFloat = 20;
    let legendHeight:CGFloat = 14;
    let yAxisWidth:CGFloat = 32;
    var baseLayer:CALayer?
    let minimumHeightForYaxisLine:CGFloat = 28;
    let minimumHWidthForXaxisLine:CGFloat = 28;
    internal var dataSource:AxisBasecChartDataSource?;
    let chartContainer:UIView = UIView()
    public var legendDataSource:LegendDataSource?
    var chartWidth:CGFloat
    {
        parentWidth - yAxisWidth-(2*leftRightPadding)
    }
    var chartHeight:CGFloat
    {
        parentHeight - xAxisHeight - (2*topBottomPadding)
    }
    func maxValue()->CGFloat?
    {
        return 0;
    }
    func minValue()->CGFloat?
    {
        return 0;
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let ctx:CGContext = UIGraphicsGetCurrentContext()
        {
            ctx.saveGState()
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = [0.0, 1.0]
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations) else {
                return
            }
            ctx.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0.0, endCenter: gradientCenter, endRadius: radius, options: CGGradientDrawingOptions(rawValue: 0))
            ctx.setLineWidth(0.6)
            ctx.setStrokeColor(UIColor.systemGray5.cgColor)
            ctx.stroke(chartFrame)
            let interval = yAxisInterval;
            if(interval != 0)
            {
                ctx.setLineWidth(1)
                var i = 1;
                while((CGFloat (i) * interval)*CGFloat(yAxisUnit) <= chartHeight)
                {
                    let value = (CGFloat (i) * interval)
                    let y = (topBottomPadding + chartHeight) - value*CGFloat(yAxisUnit)
                    ctx.move(to: CGPoint(x: leftRightPadding+yAxisWidth, y: y))
                    ctx.addLine(to: CGPoint(x: parentWidth-leftRightPadding, y: y))
                    ctx.closePath()
                    ctx.strokePath()
                    i += 1
                }
            }
            let min = minValue() ?? 0
            if(min < 0)
            {
                let xAxisdist = topBottomPadding + chartHeight + (min * CGFloat(yAxisUnit));
                ctx.setStrokeColor(UIColor.red.cgColor);
                ctx.move(to: CGPoint(x: leftRightPadding+yAxisWidth, y:xAxisdist))
                ctx.addLine(to: CGPoint(x: parentWidth-leftRightPadding, y: xAxisdist))
                ctx.closePath()
                ctx.strokePath()
            }
        }
    }
    var chartFrame:CGRect
    {
        CGRect(x: leftRightPadding+yAxisWidth, y: topBottomPadding, width: chartWidth, height: chartHeight)
    }
    var xAxisView:BasicXaxisView?
    var yAxisView:BasicYAxisView?
    var legendView:LegendView?
    func InitializeAxisViews()
    {
        initializeDefaultAxisViews();
    }
    func initializeDefaultAxisViews()
    {
        initializeDefaultYAxisView()
        initializeDefaultXAxisView();
    }
    func initializeDefaultYAxisView()
    {
        if yAxisView == nil
        {
            yAxisView = YAxisView(min: minValue() ?? 0, max: maxValue() ?? 0, frame: yAxisFrame);
            yAxisView?.clipsToBounds = false;
            yAxisView?.backgroundColor = UIColor.clear
            yAxisView?.frame = yAxisFrame
            self.addSubview(yAxisView!);
        }
    }
    func initializeDefaultXAxisView()
    {
        if xAxisView == nil
        {
            xAxisView = XAxisView(yaxisWidth: yAxisWidth,frame: xAxisFrame);
            yAxisView?.clipsToBounds = false;
            xAxisView?.backgroundColor = UIColor.clear
            self.addSubview(xAxisView!);
        }
    }
    var xAxisFrame:CGRect
    {
        CGRect(x:leftRightPadding , y: parentHeight-topBottomPadding-xAxisHeight, width: chartWidth, height: xAxisHeight);
    }
    var yAxisFrame:CGRect
    {
        CGRect(x:leftRightPadding , y: 0, width: yAxisWidth, height: chartHeight+topBottomPadding);
    }
    var gradientCenter: CGPoint {
            return CGPoint(x: leftRightPadding+yAxisWidth+chartWidth/2, y: topBottomPadding+chartHeight/2)
        }

    var radius: CGFloat {
        return (chartWidth+yAxisWidth + chartHeight)/2
    }

    var colors: [UIColor] = [UIColor.darkGray, UIColor.lightGray] {
        didSet {
            setNeedsDisplay()
        }
    }
    var legendFrame:CGRect
    {
        CGRect(x: leftRightPadding+yAxisWidth, y: 0, width: chartWidth, height: legendHeight)
    }
    var cgColors: [CGColor] {
        return colors.map({ (color) -> CGColor in
            return color.cgColor
        })
    }
    override func InitializeUIElements() {
        InitializeAxisViews()
        initializeLegendView()
    }
    func initializeLegendView()
    {
        self.legendView = LegendView(frame: legendFrame);
        self.addSubview(legendView!);
    }
    override public func reloadData(completion:@escaping (()->Void)={
        
    }) {
        self.addSubview(self.chartContainer)
        self.chartContainer.frame = chartFrame;
        self.chartContainer.backgroundColor = UIColor.clear;
        refreshXAxis();
        ReLayoutAxisViews()
        LoadLegend()
    }
    func LoadLegend()
    {
        if let legendview = legendView {
            legendview.frame = legendFrame;
            self.addSubview(legendview)
            var legend:[LegendInfo] = []
            if let src = dataSource
            {
                if(src.numberOfGroups() == 0)
                {
                    return
                }
                    
                if let legendSource = self.legendDataSource
                {
                    for grp in 0...src.numberOfGroups()-1
                    {
                        legend.append(legendSource.legendOfElementAt(group: grp));
                    }
                    legendview.legendData = legend;
                }
            }
        }
    }
    var yAxisInterval:CGFloat
    {
        get
        {
            var min = self.minValue() ?? 0
            if (min>0)
            {
                min = 0;
            }
            let max:CGFloat = self.maxValue() ?? 0;
            if max == 0 || yAxisUnit == 0
            {
                return 0;
            }
            else
            {
                return getSuitableInterval(max: max, min: min, unit: CGFloat(yAxisUnit), minHt: minimumHeightForYaxisLine, lengthToMakeInterval: chartHeight)
            }
        }
    }
    func getSuitableInterval(max:CGFloat,min:CGFloat,unit:CGFloat,minHt:CGFloat,
                             lengthToMakeInterval:CGFloat)->CGFloat
    {
        let inteval = max-min;
        let partitions = lengthToMakeInterval/minHt;
        //let singlePartitionHeight = chartHeight/partitions
        
        let roughInterval:CGFloat = inteval/partitions
        
        let digits = countDigit(n:roughInterval)
        // 12 is interval then div
        var div = CGFloat(pow(Double(10), Double( digits)))
        // normalised
        let val = roughInterval/div
        var rounded = roundf(Float(val))
        if(rounded == 0)
        {
            rounded = 1
            if(digits != 0)
            {
                div = CGFloat(pow(Double(10), Double( digits-1)))
            }
        }
        var roundedInterval = CGFloat((CGFloat(rounded) * div));
        if (roundedInterval * CGFloat(unit) < minHt)
        {
            roundedInterval = roundedInterval * 2
        }
        return roundedInterval;
    }
    func countDigit(n:CGFloat)->Int {
        return Int(floor(log10(n) + 1));
    }
    func refreshXAxis()
    {
        if xAxisView == nil
        {
            InitializeAxisViews()
        }
    }
    func ReLayoutAxisViews()
    {
        SetDefaultFramesForAxisViews()
    }
    func SetDefaultFramesForAxisViews()
    {
        xAxisView?.frame = xAxisFrame
        yAxisView?.frame = yAxisFrame
        yAxisView?.maxValue = maxValue() ?? 0
        var min = self.minValue() ?? 0
        if (min>0)
        {
            min = 0;
        }
        yAxisView?.minValue = min;
        yAxisView?.yAxisUnit = CGFloat(self.yAxisUnit);
    }
    func reloadAxisViews()
    {
        reloadXAxisView()
        reloadYAxisView()
    }
    internal func reloadXAxisView()
    {
        xAxisView?.reloadData()
        yAxisView?.maxValue = self.maxValue() ?? 0
    }
    internal func reloadYAxisView()
    {
        var min = self.minValue() ?? 0
        if (min>0)
        {
            min = 0;
        }
        yAxisView?.minValue = min;
        yAxisView?.yAxisUnit = CGFloat(self.yAxisUnit)
        yAxisView?.interval = yAxisInterval;
        yAxisView?.reloadData()
    }
    func calculateChartBasicValues()
    {
        if let max = maxValue(), var min = minValue()
        {
            if(min > 0 )
            {
                min = 0;
            }
            let interval = max-min;
            let totalValue = interval+interval*0.2
            yAxisUnit = Float(chartHeight)/Float(totalValue);
        }
    }
}
