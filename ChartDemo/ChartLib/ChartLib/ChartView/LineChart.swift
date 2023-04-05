//
//  LineChart.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 28/04/22.
//

import Foundation
import UIKit

public class LineChart:AxisBasedChart,AxisDataSource
{
    
    private var _lineChartSource:LineChartDataSource?
    public var lineChartSource: LineChartDataSource? {
        get
        {
            return _lineChartSource;
        }
        set {
            _lineChartSource = newValue
            self.dataSource = _lineChartSource;
        }
    }
    public func XAxisStringAt(index: Int) -> String {
        self.lineChartSource?.StringAt(index: index) ?? "";
    }
    public func numberOfXAxisElements() -> Int {
        self.lineChartSource?.numberOfItemsFor(group: 0) ?? 0
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
        chartWidth/CGFloat(values.map({$0.count}).max() ?? 1);
    }
    private var values:Array<Array<Float>> = [];
    public override func reloadData(completion:@escaping (()->Void)={
        
    }) {
        super.reloadData()
        if let source = self.lineChartSource
        {
            let elementGroups = source.numberOfGroups()
            if elementGroups>0
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
                calculateChartBasicValues();
                CATransaction.begin()
                CATransaction.setAnimationDuration(animationDuration)
                var usedLayers:Array<CALayer> = [];
                let min = minValue() ?? 0
                for grpIndex in 0...values.count - 1
                {
                    CATransaction.setDisableActions(true)
                    let elements = values[grpIndex];
                    var currentx:CGFloat = 0
                    var oldPath:CGMutablePath = CGMutablePath()
                    let initialPath:CGMutablePath = CGMutablePath()
                    let newPath:CGMutablePath = CGMutablePath();
                    let firstHeight = CGFloat(yAxisUnit*elements[0]);
                    var firstY = chartHeight - firstHeight;
                    var offset:CGFloat = 0;
                    if(min < 0 )
                    {
                        offset = min * CGFloat(yAxisUnit)
                    }
                    firstY = firstY + offset;
                    let firstPoint = CGPoint(x: currentx, y: firstY);
                    newPath.move(to: firstPoint)
                    initialPath.move(to: CGPoint(x: currentx, y: topBottomPadding+chartHeight))
                    currentx += xAxisWidthAllocation
                    let layers = self.chartContainer.layer.sublayers
                    for i in 1...elements.count - 1 {
                        let height = CGFloat(yAxisUnit*elements[i]);
                        var y = chartHeight - height;
                        y = y + offset;
                        newPath.addLine(to: CGPoint(x: currentx, y: y))
                        newPath.closeSubpath()
                        newPath.move(to: CGPoint(x: currentx, y: y))
                        initialPath.addLine(to: CGPoint(x: currentx, y: topBottomPadding+chartHeight))
                        initialPath.closeSubpath()
                        initialPath.move(to: CGPoint(x: currentx, y: topBottomPadding+chartHeight))
                        currentx += xAxisWidthAllocation
                    }
                    var currentLayer:CAShapeLayer?
                    if let castLayers = layers,grpIndex<=castLayers.count-1
                        ,let shapeLayer = castLayers[grpIndex] as? CAShapeLayer
                    {
                        currentLayer = shapeLayer
                        oldPath = currentLayer?.path as! CGMutablePath;
                    }
                    else
                    {
                        currentLayer = CAShapeLayer();
                        oldPath = initialPath;
                        self.chartContainer.layer.addSublayer(currentLayer!);
                    }
                    currentLayer?.frame = chartContainer.bounds
                    currentLayer?.strokeColor = self.lineChartSource?.colorOfElementAt(group: grpIndex);
                    CATransaction.setDisableActions(false)
                    let animation = CABasicAnimation()
                    animation.fromValue = oldPath
                    animation.toValue = newPath;
                    animation.duration = animationDuration;
                    animation.keyPath = "path"
                    currentLayer?.add(animation, forKey: "path");
                    currentLayer?.path = newPath;
                    usedLayers.append(currentLayer!);
                }
                let allLayers = self.chartContainer.layer.sublayers
                let unusedLayers = allLayers?.filter({!usedLayers.contains($0)})
                unusedLayers?.forEach({$0.removeFromSuperlayer()})
                CATransaction.commit()
                xAxisView?.dataSource = self;
                reloadAxisViews();
            }
            self.setNeedsDisplay()
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
