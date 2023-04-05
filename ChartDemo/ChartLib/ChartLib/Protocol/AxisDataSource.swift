//
//  AxisDataSource.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 29/04/22.
//

import Foundation
public protocol AxisDataSource
{
    func numberOfXAxisElements()->Int;
    func XAxisStringAt(index:Int)->String;
}
