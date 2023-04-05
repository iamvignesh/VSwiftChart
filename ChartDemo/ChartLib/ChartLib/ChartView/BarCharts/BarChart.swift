//
//  BarChart.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 28/04/22.
//

import Foundation
import QuartzCore
import UIKit
public class GroupContainer:CALayer
{
    
}
public class BarChart:AxisBasedChart,AxisDataSource
{
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
    private var barGroupWidth:CGFloat
    {
        get
        {
            return widthAllocation*0.6;
        }
    }
    private var values:Array<Array<Float>> = [];
    public override func reloadData(completion:@escaping (()->Void)={
        
    }) {
        super.reloadData()
        if let source = self.barChartSource
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
                
                let groupLayers = Array<CALayer>(self.chartContainer.layer.sublayers ?? Array<CALayer>());
                var remainingGroupLayers = Array<CALayer>(groupLayers);
                calculateChartBasicValues();
                var needDoubleAnimation = false;
                var offset:CGFloat = 0;
                let min = minValue() ?? 0
                if(min < 0 )
                {
                    offset = min * CGFloat(yAxisUnit)
                }
                for grpIndex in 0...values.count-1
                {
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
                    let grpElements = values[grpIndex]
                    let singleBarWidth = barGroupWidth/CGFloat(elementGroups);
                    var currentx:CGFloat = CGFloat(grpIndex)*singleBarWidth;
                    let barLayers = Array<CALayer>(barGroupLayer!.sublayers ?? Array<CALayer>());
                    var remainingLayers = Array<CALayer>(barLayers);
                    for i in 0...grpElements.count-1 {
                        var currentLayer:CAShapeLayer?
                        var isExisting = false
                        CATransaction.setDisableActions(true)
                        if barLayers.count-1 >= i
                        {
                            if let layerAtIndex = barLayers[i] as? CAShapeLayer
                            {
                                layerAtIndex.removeFromSuperlayer();
                                currentLayer = layerAtIndex;
                                isExisting = true;
                                remainingLayers.removeAll(where: {$0==layerAtIndex})
                            }
                            else
                            {
                                currentLayer = CAShapeLayer()
                                needDoubleAnimation = true;
                            }
                        }
                        else
                        {
                            currentLayer = CAShapeLayer();
                            needDoubleAnimation = true;
                        }
                        
                        let height = CGFloat(yAxisUnit*grpElements[i]);
                        let y = chartHeight - height
                        var newRect = CGRect(x: currentx, y:y , width: singleBarWidth, height: height)
                        
                        newRect = newRect.offsetBy(dx: 0, dy: offset);
                        currentLayer?.backgroundColor = self.barChartSource?.colorOfElementAt(group: grpIndex, index: i)
                        
                        barGroupLayer!.addSublayer(currentLayer!);
                        CATransaction.setDisableActions(false)
                        if(isExisting)
                        {
                            currentLayer?.frame = newRect//chartContainer.bounds//
                        }
                        else
                        {
                            var zeroheightRect = newRect.offsetBy(dx: 0, dy: newRect.height)
                            zeroheightRect.size.height = 0
                            currentLayer?.frame = zeroheightRect;
                        }
                        currentx += widthAllocation
                    }
                    CATransaction.setDisableActions(true)
                    remainingLayers.forEach { c in
                        c.removeFromSuperlayer()
                    }
                    CATransaction.setDisableActions(false)
                }
                CATransaction.setDisableActions(true)
                remainingGroupLayers.forEach({$0.removeFromSuperlayer()})
                CATransaction.setDisableActions(false)
                CATransaction.setCompletionBlock {
                    if(needDoubleAnimation)
                    {
                        self.reloadData()
                    }
                }
                CATransaction.commit()
                xAxisView?.dataSource = self;
                reloadAxisViews();
                ReLayoutAxisViews()
            }
            self.setNeedsDisplay()
        }
    }
    override func InitializeAxisViews() {
        initializeDefaultAxisViews()
        xAxisView?.frame = xAxisFrame.offsetBy(dx: barGroupWidth/2.0, dy: 0)
    }
    override func ReLayoutAxisViews() {
        SetDefaultFramesForAxisViews()
        xAxisView?.frame = xAxisFrame.offsetBy(dx: barGroupWidth/2.0, dy: 0)
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
    override func maxValue() -> CGFloat? {
        return values.map({CGFloat($0.max() ?? 0)}).max()
    }
    
    override func minValue()->CGFloat?
    {
        return values.map({CGFloat($0.min() ?? 0)}).min()
    }
}
