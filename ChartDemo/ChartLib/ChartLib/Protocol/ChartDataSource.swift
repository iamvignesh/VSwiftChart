//
//  ChartDataSource.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 28/04/22.
//

import Foundation
import CoreGraphics
public protocol ChartDataSource:AxisBasecChartDataSource
{
    func numberOfItemsFor(group:Int)->Int
    func valueOfElementAt(group:Int, index:Int)->Float
    func StringAt(index:Int)->String;
}
public protocol BarChartDataSource:ChartDataSource
{
    func colorOfElementAt(group:Int, index:Int)->CGColor
}

public protocol LineChartDataSource:ChartDataSource
{
    func colorOfElementAt(group:Int)->CGColor
}

public protocol LegendDataSource
{
    func legendOfElementAt(group:Int)->LegendInfo
}
public protocol AxisBasecChartDataSource
{
    func numberOfGroups()->Int
}
