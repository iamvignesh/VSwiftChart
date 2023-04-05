//
//  CGPoint+Extension.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 17/06/22.
//

import Foundation
import UIKit
extension CGPoint
{
    func getDistance(point:CGPoint)->Double
    {
        let xdist:Double = point.x-self.x;
        let ydist:Double = point.y-self.y;
        let squaredDist = (xdist*xdist) + (ydist*ydist)
        return squaredDist.squareRoot();
    }
}
