//
//  StackedBarChart.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 16/10/22.
//

import Foundation
import CoreGraphics
import UIKit

public class StackedBarChart:AxisBasedChart,AxisDataSource
{
    // MARK: Overrides
    override func InitializeAxisViews() {
        initializeDefaultAxisViews()
        xAxisView?.frame = xAxisFrame.offsetBy(dx: singleBarWidth/2.0, dy: 0)
    }
    override func ReLayoutAxisViews() {
        SetDefaultFramesForAxisViews()
        xAxisView?.frame = xAxisFrame.offsetBy(dx: singleBarWidth/2.0, dy: 0)
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if(values.count > 0)
        {
            var currentx:CGFloat = yAxisWidth + leftRightPadding
            if let ctx:CGContext = UIGraphicsGetCurrentContext()
            {
                ctx.setStrokeColor(UIColor.systemGray4.cgColor)
                ctx.setLineWidth(1);
                for _ in 0...(values.map({$0.count}).max() ?? 1) - 1
                {
                    let y = topBottomPadding+chartHeight
                    ctx.move(to: CGPoint(x: currentx, y: y))
                    ctx.addLine(to: CGPoint(x: currentx, y: y+5))
                    ctx.closePath()
                    ctx.strokePath()
                    currentx += xAxisWidthAllocation;
                }
            }
        }
    }
    override func maxValue() -> CGFloat? {
        var max:Float = 0
        if(values.count > 0)
        {
            for currIndex in 0...maxArrayCount-1 {
                var indexValSum:Float = 0;
                for arrIndex in 0...values.count-1
                {
                    let arr = values[arrIndex]
                    
                    if(currIndex < arr.count)
                    {
                        if arr[currIndex] > 0 {
                            indexValSum += arr[currIndex]
                        }
                    }
                }
                if(indexValSum > max)
                {
                    max = indexValSum;
                }
            }
        }
        return CGFloat(max);
    }
    override func minValue()->CGFloat?
    {
        var min:Float = 0
        if(values.count > 0)
        {
            for currIndex in 0...maxArrayCount-1 {
                var indexValSum:Float = 0;
                for arrIndex in 0...values.count-1
                {
                    let arr = values[arrIndex]
                    
                    if(currIndex < arr.count)
                    {
                        if arr[currIndex] < 0 {
                            indexValSum += arr[currIndex]
                        }
                    }
                }
                if(indexValSum < min)
                {
                    min = indexValSum;
                }
            }
        }
        return CGFloat(min);
    }
    public override func reloadData(completion:@escaping (()->Void)={
        
    }) {
        super.reloadData()
        if let source = self._barChartSource
        {
            let elementGroups = source.numberOfGroups()
            if(elementGroups>0)
            {
                values = [];
                
                for grp in 0...elementGroups-1
                {
                    values.append(Array<Float>());
                    let elementsCount = source.numberOfItemsFor(group: grp);
                    if elementsCount > 0
                    {
                        for i in  0...elementsCount-1
                        {
                            values[grp].append(source.valueOfElementAt(group: grp, index: i));
                        }
                    }
                }
                CATransaction.begin()
                CATransaction.setAnimationDuration(animationDuration)
                var needDoubleAnimation = false;
                let groupLayers = Array<CALayer>(self.chartContainer.layer.sublayers ?? Array<CALayer>());
                var remainingGroupLayers = Array<CALayer>(groupLayers);
                calculateChartBasicValues();
                var currentx:CGFloat = 0
                for grpIndex in 0...maxArrayCount-1
                {
                    CATransaction.setDisableActions(true)
                    var barGroupLayer:GroupContainer?
                    if groupLayers.count-1 >= grpIndex
                    {
                        let layerAtIndex = groupLayers[grpIndex] as? GroupContainer
                        if let exist = layerAtIndex
                        {
                            barGroupLayer = exist;
                            remainingGroupLayers.removeAll(where: {$0==exist})
                        }
                        else
                        {
                            barGroupLayer = GroupContainer()
                            self.chartContainer.layer.addSublayer(barGroupLayer!);
                        }
                    }
                    else
                    {
                        barGroupLayer = GroupContainer();
                        self.chartContainer.layer.addSublayer(barGroupLayer!);
                    }
                    
                    barGroupLayer?.frame = chartContainer.bounds;
                    var grpElements:[Float?] = []
                    for grp in 0...values.count-1
                    {
                        let arr = values[grp]
                        var elemnt:Float?
                        if grpIndex < arr.count
                        {
                            elemnt = arr[grpIndex]
                        }
                        grpElements.append(elemnt);
                    }
                    
                    var offset:CGFloat = 0;
                    let min = minValue() ?? 0
                    if(min < 0 )
                    {
                        offset = min * CGFloat(yAxisUnit)
                    }
                    let barLayers = Array<CALayer>(barGroupLayer!.sublayers ?? Array<CALayer>());
                    var remainingLayers = Array<CALayer>(barLayers);
                    var positiveYGrowth:CGFloat = 0;
                    var negativeYGrowth:CGFloat = 0;
                    CATransaction.setDisableActions(false)
                    for i in 0...grpElements.count-1 {
                        var currentLayer:CAShapeLayer?
                        CATransaction.setDisableActions(true)
                        var isExisting = false;
                        if barLayers.count-1 >= i
                        {
                            let layerAtIndex = barLayers[i] as? CAShapeLayer
                            if let exist = layerAtIndex
                            {
                                exist.removeFromSuperlayer();
                                currentLayer = exist;
                                isExisting = true;
                                remainingLayers.removeAll(where: {$0==exist})
                            }
                            else
                            {
                                currentLayer = CAShapeLayer()
                                needDoubleAnimation = true;
                                let val = CGRect(x: currentx, y: (chartHeight-positiveYGrowth), width: singleBarWidth, height: 0);
                                currentLayer?.frame = val
                            }
                        }
                        else
                        {
                            currentLayer = CAShapeLayer();
                            needDoubleAnimation = true;
                            let val = CGRect(x: currentx, y: (chartHeight-positiveYGrowth), width: singleBarWidth, height: 0);
                            currentLayer?.frame = val
                        }
                        let height = CGFloat(yAxisUnit*(grpElements[i] ?? 0));
                        var y = chartHeight - (height + positiveYGrowth);
                        if(height < 0)
                        {
                            y = chartHeight - (height - negativeYGrowth);
                        }
                        var toValue = CGRect(x: currentx, y:y , width: singleBarWidth, height: height)
                        toValue = toValue.offsetBy(dx: 0, dy: offset);
                        currentLayer?.backgroundColor = self.barChartSource?.colorOfElementAt(group: i, index: grpIndex)
                        barGroupLayer!.addSublayer(currentLayer!);
                        
                        CATransaction.setDisableActions(false)
                        if(isExisting)
                        {
                            currentLayer?.frame = toValue;
                        }
                        if(height >= 0)
                        {
                            positiveYGrowth += height;
                        }
                        else
                        {
                            negativeYGrowth += height;
                        }
                    }
                    CATransaction.setDisableActions(true)
                    remainingLayers.forEach { c in
                        c.removeFromSuperlayer()
                    }
                    CATransaction.setDisableActions(false)
                    currentx += widthAllocation
                }
                CATransaction.setDisableActions(true)
                remainingGroupLayers.forEach({$0.removeFromSuperlayer()})
                CATransaction.setDisableActions(false)
                CATransaction.setCompletionBlock {
                    if(needDoubleAnimation)
                    {
                        self.reloadData();
                    }
                    print("needDoubleAnimation = \(needDoubleAnimation)")
                }
                CATransaction.commit()
                xAxisView?.dataSource = self;
                reloadAxisViews();
                ReLayoutAxisViews()
            }
            self.setNeedsDisplay()
        }
    }
    // MARK: Overrides End
    private var _barChartSource:BarChartDataSource?
    public var barChartSource: BarChartDataSource? {
        get
        {
            return _barChartSource;
        }
        set {
            _barChartSource = newValue
            self.dataSource = _barChartSource;
        }
    }
    public func XAxisStringAt(index: Int) -> String {
        self._barChartSource?.StringAt(index: index) ?? "";
    }
    public func numberOfXAxisElements() -> Int {
        self._barChartSource?.numberOfItemsFor(group: 0) ?? 0;
    }
    private var  widthAllocation:CGFloat
    {
        get
        {
            return chartWidth/CGFloat(values.map({$0.count}).max() ?? 1);
        }
    }
    private var  singleBarWidth:CGFloat
    {
        get
        {
            return  widthAllocation*0.4;
        }
    }
    
    private var values:Array<Array<Float>> = [];
    
    private var xAxisWidthAllocation:CGFloat
    {
        chartWidth/CGFloat(maxArrayCount);
    }
    private var maxArrayCount:Int
    {
        get
        {
            return values.map({$0.count}).max() ?? 1;
        }
    }
    
}

