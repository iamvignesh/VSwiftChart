//
//  BubbleChart.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 25/02/23.
//

import Foundation
import CoreGraphics
import UIKit


public class BubbleChart:AxisBasedChart,AxisDataSource
{
    var data:Array<BubbleData> = Array<BubbleData>();
    
    public func numberOfXAxisElements() -> Int {
        return data.count;
    }
    
    public func XAxisStringAt(index: Int) -> String {
        return "";
    }
    
    // MARK: Overrides
    override func InitializeAxisViews() {
        initializeDefaultAxisViews()
    }
    override func ReLayoutAxisViews() {
        SetDefaultFramesForAxisViews()
    }
    var xAxisLines:CGFloat = 5;
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if(data.count > 0)
        {
            let xMax = data.map({CGFloat($0.X)}).max() ?? 0
            if(xMax > 0)
            {
                var currentx:CGFloat = yAxisWidth + leftRightPadding
                if let ctx:CGContext = UIGraphicsGetCurrentContext()
                {
                    ctx.setStrokeColor(UIColor.systemGray4.cgColor)
                    ctx.setLineWidth(1);
                    for _ in 0...(Int(xAxisLines)-1) {
                        let y = topBottomPadding+chartHeight
                        ctx.move(to: CGPoint(x: currentx, y: y))
                        ctx.addLine(to: CGPoint(x: currentx, y: y+5))
                        ctx.closePath()
                        ctx.strokePath()
                        currentx += chartWidth/xAxisLines;
                    }
                }
            }
        }
    }
    private var _bubbleDataSource:BubbleDataSource?
    public var bubbleDataSource: BubbleDataSource? {
        get
        {
            return _bubbleDataSource;
        }
        set {
            _bubbleDataSource = newValue
            self.dataSource = _bubbleDataSource;
        }
    }
    override func maxValue() -> CGFloat? {
        if(data.count > 0)
        {
            return data.map({CGFloat($0.Y )}).max()
        }
        return 0;
    }
    override func minValue()->CGFloat?
    {
        if(data.count > 0)
        {
            return data.map({CGFloat($0.Y )}).min()
        }
        return 0;
    }
    public override func reloadData(completion:@escaping (()->Void)={
        
    }) {
        super.reloadData()
        if self.dataSource != nil
        {
            self.setNeedsDisplay()
            
            if let source = dataSource as? BubbleDataSource
            {
                data.removeAll()
                
                let itemsCount = source.getCount()
                for item in 0...itemsCount-1
                {
                    data.append(source.getData(index: item))
                }
            }
            calculateChartBasicValues();
            let min = minValue() ?? 0
            CATransaction.begin()
            CATransaction.setAnimationDuration(animationDuration)
            var usedLayers:Array<CALayer> = [];
            let xMax = data.map({CGFloat($0.X)}).max() ?? 0
            let xaxisUnit = chartWidth / xMax
            for index in 0...data.count - 1
            {
                CATransaction.setDisableActions(true)
                let bubble = data[index];
                var oldPath:CGMutablePath = CGMutablePath()
                let initialPath:CGMutablePath = CGMutablePath()
                let newPath:CGMutablePath = CGMutablePath();
                let firstHeight = CGFloat(yAxisUnit) * bubble.Y;
                var yValue = chartHeight - firstHeight;
                var offset:CGFloat = 0;
                if(min < 0 )
                {
                    offset = min * CGFloat(yAxisUnit)
                }
                yValue = yValue + offset;
                let layers = self.chartContainer.layer.sublayers
                let x = leftRightPadding/2 + xaxisUnit * bubble.X;
                let rad = zAxisUnit * GetRadiusFromArea(a: bubble.V)
                newPath.addArc(center: CGPoint(x: x, y: yValue), radius: rad, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true);
                newPath.closeSubpath();
                var currentLayer:CAShapeLayer?
                if let castLayers = layers,index<=castLayers.count-1
                    ,let shapeLayer = castLayers[index] as? CAShapeLayer
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
                currentLayer?.fillColor = UIColor.blue.withAlphaComponent(0.6).cgColor;
                var textlr:CATextLayer?
                for layer in currentLayer!.sublayers ?? Array<CALayer>()
                {
                    if let textLayer = layer as? CATextLayer
                    {
                        textlr = textLayer;
                    }
                }
                let fontSize:CGFloat = rad*0.4;
                let font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
                var oldRect:CGRect = CGRect.zero
                if(textlr == nil)
                {
                    textlr = CATextLayer();
                    textlr!.font = font
                    textlr?.fontSize = fontSize
                    textlr!.alignmentMode = .center
                    textlr!.isWrapped = true
                    textlr!.truncationMode = .end
                    textlr!.backgroundColor = UIColor.clear.cgColor
                    textlr!.foregroundColor = UIColor.white.cgColor
                    currentLayer?.addSublayer(textlr!);
                }
                else
                {
                    oldRect = textlr!.frame;
                }
                let rect = CGRect(x: x, y: yValue, width: rad*2, height: rad*2);
                let intVal = Int(bubble.V);
                let strValue = "\(intVal)"
                let ht = strValue.height(withConstrainedWidth: rad*2, font: font) + 6
                var offsetrct = rect.offsetBy(dx: -rad, dy: -ht/2)
                offsetrct.size.height = ht;
                textlr!.string = strValue;
                
                
                CATransaction.setDisableActions(false)
                let txtAnim = CABasicAnimation()
                txtAnim.fromValue = oldRect
                txtAnim.toValue = offsetrct;
                txtAnim.duration = animationDuration*1.4;
                txtAnim.keyPath = "frame"
                textlr!.add(txtAnim, forKey: "frame");
                textlr!.frame = offsetrct;
                
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
            reloadAxisViews()
        }
    }
    func GetRadiusFromArea(a:CGFloat) -> CGFloat
    {
        return sqrt((a/CGFloat.pi));
    }
    var zAxisUnit:CGFloat = 0;
    
    // MARK: Overrides End
    override func calculateChartBasicValues() {
        
        super.calculateChartBasicValues();
        
        let xMax = data.map({CGFloat($0.X)}).max() ?? 0
        // number of realtimedata perunit of xaxis
        xAxisUnit = Float(chartWidth/xMax)
        
        let possibleRadius = min(chartWidth, chartHeight)/2
        let paddedRadius = possibleRadius/4
        let maxZ = data.map({CGFloat($0.V)}).max() ?? 0
        
        let valueMaxRad = GetRadiusFromArea(a: maxZ)// sqrt((maxZ/CGFloat.pi))
        // numberofViewUnitsPerRealTimeValue
        zAxisUnit = paddedRadius/valueMaxRad;
    }
    override func initializeDefaultXAxisView() {
        if(xAxisView == nil)
        {
            let axisView = XaxisViewWithScale(min: self.minValue() ?? 0, max: self.maxValue() ?? 0, frame: xAxisFrame, yaxisWidth: yAxisFrame.width, unit: CGFloat(xAxisUnit));
            axisView.clipsToBounds = false;
            axisView.backgroundColor = UIColor.clear
            self.addSubview(axisView);
            xAxisView = axisView;
        }
    }
    override func reloadXAxisView() {
        if let axisView = xAxisView as? XaxisViewWithScale
        {
            axisView.minValue = minValue() ?? 0
            axisView.maxValue = maxValue() ?? 0
            
            var min = data.map({$0.X}).min() ?? 0
            if (min>0)
            {
                min = 0;
            }
            let max = data.map({$0.X}).max() ?? 0
            axisView.minValue = min;
            axisView.xAxisUnit = CGFloat(self.xAxisUnit)
            axisView.maxValue = max
            if max == 0 || xAxisUnit == 0
            {
                yAxisView?.interval = 0;
            }
            else
            {
                axisView.interval = getSuitableInterval(max: max, min: min, unit: CGFloat(xAxisUnit), minHt: minimumHWidthForXaxisLine, lengthToMakeInterval: chartWidth)
            }
            
            xAxisView?.reloadData()
        }
    }
}
