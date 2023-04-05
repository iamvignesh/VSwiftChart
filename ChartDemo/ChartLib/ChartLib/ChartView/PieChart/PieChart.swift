//
//  PieChart.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 03/05/22.
//

import Foundation
import UIKit

public protocol PichartDataSource
{
    func numberOfItemsFor(selectionList:[Int],selectionIndex:Int) -> Int
    func valueAt(selectionList:[Int],selectionIndex:Int, of index:Int)->Double
    func hasChildren(selectionList:[Int],index:Int)->Bool
}
public struct SlicePath
{
    public var circleIndex:Int = -1;
    public var sliceIndex:Int = -1;
    init(circle:Int,slice:Int) {
        self.circleIndex = circle
        self.sliceIndex = slice;
    }
}
public class PieValue
{
    var value:Double = 0;
    init(value: Double) {
        self.value = value;
    }
}
public class Circle
{
    var slices:[PieValue]
    init(slices:[PieValue])
    {
        self.slices = slices;
    }
}
public class PieChart:ChartBase,CAAnimationDelegate
{
    let chartContainer:UIView = UIView()
    var selectedItems:[Int] = [];
    var circleList:[Circle] = [];
    var pieCenter:CGPoint = CGPoint();
    let tapgesture:UITapGestureRecognizer = UITapGestureRecognizer();
    var radius:CGFloat
    {
        get
        {
            return centerX < centerY ? centerX:centerY
        }
    };
    var centerX:CGFloat
    {
        get
        {
            return self.bounds.width/2
        }
    };
    var centerY:CGFloat
    {
        get
        {
            return self.bounds.height/2
        }
    };
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeBeforeUsage()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeBeforeUsage()
    }
    private var animationCompletion:(()->Void)?
    func initializeBeforeUsage() {
        tapgesture.addTarget(self, action: #selector(tapped(sender:)))
        self.addGestureRecognizer(tapgesture)
    }
    @objc func tapped(sender:UITapGestureRecognizer)
    {
        let position = sender.location(in: self)
        let path = getSelectedSlicePath(position: position);
        if path.circleIndex > -1
        {
            if path.circleIndex <= (selectedItems.count-1)
            {
                selectedItems[path.circleIndex] = path.sliceIndex;
                selectedItems.removeLast(selectedItems.count-(path.circleIndex+1))
                circleList.removeLast(circleList.count-(path.circleIndex+1))
                reloadData()
            }
            if path.circleIndex>=selectedItems.count
            {
                selectedItems.append(path.sliceIndex)
                reloadData()
            }
        }
    }
    public var dataSource: PichartDataSource?
    
    private func getSelectedSlicePath(position:CGPoint)->SlicePath
    {
        let layers = chartContainer.layer.sublayers as? Array<WholeCircleLayer> ?? [];
        var slicePath = SlicePath(circle: -1, slice: -1)
        let distanceFromCenter = position.getDistance(point: self.pieCenter)
        for circleIndex in 0...layers.count-1
        {
            let wholeCircle = layers[circleIndex]
            if(wholeCircle.radius>distanceFromCenter)
            {
                let pieLayers:[SliceLayer] = wholeCircle.sublayers?.filter({$0.isKind(of: SliceLayer.self)}) as? [SliceLayer] ?? [];
                for sliceIndex in 0...pieLayers.count-1
                {
                    let slice = pieLayers[sliceIndex]
                    if let path = slice.path, path.contains(position)
                    {
                        slicePath.sliceIndex = sliceIndex;
                        break;
                    }
                }
                if(slicePath.sliceIndex != -1)
                {
                    slicePath.circleIndex = circleIndex;
                    break;
                }
            }
        }
        return slicePath;
    }
    var singleCircleRadius:CGFloat
    {
        get
        {
            return radius/(CGFloat(circleList.count))
        }
    }
    
    private func addRadiusAnimation(completion:@escaping (()->Void) = {})
    {
        let layers = chartContainer.layer.sublayers as? Array<WholeCircleLayer> ?? [];
        let clipRadiusKey = #keyPath(SliceLayer.clipRadius)
        let radiusKey = #keyPath(SliceLayer.radius)
        var clippingRadius:CGFloat = 0;
        let animationTime = 0.5
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion);
        CATransaction.setAnimationDuration(animationTime)
        for circleIndex in 0...layers.count-1
        {
            let wholeCircle = layers[circleIndex]
            let circleRadius = CGFloat(circleIndex+1) * singleCircleRadius;
            let pieLayers:[SliceLayer] = wholeCircle.sublayers?.filter({$0.isKind(of: SliceLayer.self)}) as? [SliceLayer] ?? [];
            for sliceIndex in 0...pieLayers.count-1
            {
                let slice = pieLayers[sliceIndex]
                slice.AddAnimation(newValue: circleRadius,oldValue:slice.radius,
                                   for: radiusKey, duration: animationTime,
                                   timingName: CAMediaTimingFunctionName.easeInEaseOut,
                                    isDamping: true)
                slice.AddAnimation(newValue: clippingRadius,oldValue:slice.clipRadius,
                                    for: clipRadiusKey, duration: animationTime,
                                   timingName: CAMediaTimingFunctionName.easeInEaseOut,
                                   isDamping: true)
                slice.radius = circleRadius;
                slice.clipRadius = clippingRadius;
            }
            print("Radius = \(circleRadius) ClipRadius = \(clippingRadius)")
            clippingRadius = circleRadius;
        }
        CATransaction.commit()
    }
    override public func reloadData(completion:@escaping (()->Void) = {})
    {
        var prevData:[Circle] = []
        prevData.append(contentsOf: circleList);
        circleList = [];
        if let source = self.dataSource
        {
            self.addSubview(self.chartContainer)
            self.chartContainer.frame = self.bounds;
            self.chartContainer.backgroundColor = UIColor.clear;
            
            
            self.pieCenter = CGPoint(x: centerX, y: centerY)
            
            
            var pieValues:[PieValue] = [];
            let parentSlices = source.numberOfItemsFor(selectionList: [], selectionIndex: 0)
            for selectionIndex in 0...(parentSlices-1) {
                let value = source.valueAt(selectionList: [], selectionIndex: 0, of: selectionIndex)
                pieValues.append(PieValue(value: value))
            }
            circleList.append(Circle(slices: pieValues))
            if(selectedItems.count > 0)
            {
                for selectionItemIndex in 0...selectedItems.count-1 {
                    if prevData.count > selectionItemIndex+1
                    {
                        circleList.append(prevData[selectionItemIndex+1])
                    }
                    else
                    {
                        if source.hasChildren(selectionList: selectedItems, index: selectionItemIndex)
                        {
                            var innerSlices:[PieValue] = [];
                            let slices = source.numberOfItemsFor(selectionList: selectedItems, selectionIndex: selectionItemIndex)
                            for sliceIndex in 0...(slices-1) {
                                let value = source.valueAt(selectionList: selectedItems, selectionIndex: selectionItemIndex, of: sliceIndex)
                                innerSlices.append(PieValue(value: value))
                            }
                            circleList.append(Circle(slices: innerSlices))
                        }
                    }
                }
            }
            var layers = chartContainer.layer.sublayers as? Array<WholeCircleLayer> ?? [];
            if layers.count > 0, layers.count<circleList.count
            {
                addRadiusAnimation {
                    self.AddCicleAnimation()
                }
            }
            else
            {
                if(layers.count != 0)
                {
                    let additionalLayers = layers.suffix(layers.count-circleList.count)
                    additionalLayers.forEach({$0.removeFromSuperlayer()})
                    layers = layers.filter({!additionalLayers.contains($0)})
                    addRadiusAnimation {
                        self.AddCicleAnimation()
                    }
                }
                else
                {
                    self.AddCicleAnimation()
                }
            }
        }
    }
    func AddCicleAnimation() {
        let layers = chartContainer.layer.sublayers as? Array<WholeCircleLayer> ?? [];
        var remainingGroupLayers = Array<WholeCircleLayer>(layers);
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        var clippingRadius:CGFloat = 0;
        var selectedPieCenterAngle:CGFloat = 0;
        for circleDataIndex in 0...circleList.count-1 {
            let circleData = circleList[circleDataIndex]
            let circleRadius = CGFloat(circleDataIndex+1) * singleCircleRadius;
            var wholeCircle:WholeCircleLayer?;
            if layers.count > circleDataIndex
            {
                wholeCircle = layers[circleDataIndex]
                remainingGroupLayers.removeAll(where:{$0==wholeCircle});
            }
            else
            {
                wholeCircle = WholeCircleLayer();
                wholeCircle?.frame = self.bounds;
                chartContainer.layer.insertSublayer(wholeCircle!, at: UInt32(circleDataIndex));
                wholeCircle?.startAngle = selectedPieCenterAngle;
            }
            wholeCircle?.center = pieCenter;
            wholeCircle?.radius = circleRadius;
            let isOdd = (circleDataIndex%2==0)
            let fillColor = UIColor.init(red:isOdd ? 1:0 , green: isOdd ? 0:1, blue: 1, alpha: 1);
            let piesCount = circleData.slices.count
            if piesCount > 0
            {
                var values:Array<Double> = [];
                for pieIndex in 0...piesCount-1 {
                    values.append(circleData.slices[pieIndex].value)
                }
                let pieLayers:[SliceLayer] = wholeCircle!.sublayers?.filter({$0.isKind(of: SliceLayer.self)}) as? [SliceLayer] ?? [];
                var unUsedLayers:[SliceLayer] = Array<SliceLayer>(pieLayers);
                let total = values.reduce(0,+);
                let degreePerUnitValue:CGFloat = CGFloat(360.0/total);
                var startingAngle:CGFloat = 0;
                let radiansPerDegree = CGFloat.pi/180.0
                var selectedIndex = -1
                if selectedItems.count>circleDataIndex
                {
                    selectedIndex = selectedItems[circleDataIndex]
                }
                
                for pieValueIndex in (0...circleData.slices.count-1)
                {
                    let angleCoverage:CGFloat = CGFloat(values[pieValueIndex]) * degreePerUnitValue
                    let endAngle = startingAngle + CGFloat(angleCoverage)
                    let startRadians = startingAngle * radiansPerDegree
                    //let angleCoverageRadians = angleCoverage * radiansPerDegree;
                    let endAngleRandians = endAngle*radiansPerDegree
                    var slice:SliceLayer?;
                    //var sliceData = circleData.slices[pieValueIndex];
                    CATransaction.setDisableActions(true)
                    let endKey = #keyPath(SliceLayer.endAngle)
                    let startKey = #keyPath(SliceLayer.startAngle)
                    //let radiusKey = #keyPath(SliceLayer.radius)
                    var angleStartFromValue:CGFloat = 0;
                    var angleEndFromValue:CGFloat = 0
                    if pieValueIndex < pieLayers.count
                    {
                        slice = pieLayers[pieValueIndex]
                        angleStartFromValue = ((slice!.value(forKey: startKey) as? CGFloat) ?? 0);
                        angleEndFromValue = ((slice!.value(forKey: endKey) as? CGFloat) ?? 0);
                        unUsedLayers.removeAll(where:{$0==slice});
                    }
                    else
                    {
                        slice = SliceLayer()
                        angleStartFromValue = wholeCircle!.startAngle
                        angleEndFromValue = wholeCircle!.startAngle
                        wholeCircle!.insertSublayer(slice!, at: UInt32(pieValueIndex));
                    }
                    let isSelected = selectedIndex == pieValueIndex;
                    slice?.clipRadius = clippingRadius
                    CATransaction.setDisableActions(false)
                    slice!.center = pieCenter
                    slice!.frame = self.bounds
                    slice!.lineWidth = 1
                    slice?.startAngle = slice?.startAngle ?? 0 + wholeCircle!.startAngle;
                    slice?.endAngle = slice?.endAngle ?? 0 + wholeCircle!.startAngle;
                    slice!.sliceFillColor = fillColor.cgColor
                    slice?.isSelected = isSelected;
                    slice!.strokeColor = UIColor.black.cgColor
                    slice?.radius = circleRadius
                    slice?.AddAnimation(newValue: wholeCircle!.startAngle + endAngleRandians,oldValue:angleEndFromValue, for: endKey, duration: animationDuration)
                    slice?.AddAnimation(newValue:wholeCircle!.startAngle + startRadians,oldValue:angleStartFromValue, for: startKey, duration: animationDuration)
                    if isSelected
                    {
                        selectedPieCenterAngle = wholeCircle!.startAngle + startRadians + ((endAngleRandians-startRadians)/2)
                    }
                    startingAngle = endAngle;
                }
                //wholeCircle?.AddClipAnimation(newValue: clippingRadius, duration: animationDuration);
                CATransaction.setDisableActions(true)
                unUsedLayers.forEach({$0.removeFromSuperlayer()})
                CATransaction.setDisableActions(false)
            }
            clippingRadius = circleRadius;
        }
        CATransaction.setDisableActions(true)
        remainingGroupLayers.forEach({$0.removeFromSuperlayer()})
        CATransaction.setDisableActions(false)
        CATransaction.commit()
    }
}
