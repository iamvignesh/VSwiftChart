//
//  BubbleChart.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 25/03/23.
//

import Foundation
import CoreGraphics
public protocol BubbleDataSource:AxisBasecChartDataSource
{
    func getCount()->Int;
    func getData(index:Int)->BubbleData
}
