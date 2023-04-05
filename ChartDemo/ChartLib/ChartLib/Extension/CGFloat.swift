//
//  CGFloat.swift
//  ChartLib
//
//  Created by Vignesh Kumar Subramaniam on 20/06/22.
//

import Foundation
import UIKit
extension CGFloat
{
    func isEqual(b: CGFloat) -> Bool {
        return abs(self - b) < CGFloat.ulpOfOne
    }
}
