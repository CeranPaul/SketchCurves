//
//  PenCurve.swift
//  SketchCurves
//
//  Created by Paul on 10/30/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import UIKit

public protocol PenCurve   {
    
    /// The enum that hints at the meaning of the curve
    var usage: PenTypes   { get set }
    
    /// Volume that encloses the curve
    var extent: OrthoVol   { get }
    
    
    /// Supply the point on the curve for the input parameter value
    func pointAt(_ t: Double) -> Point3D
    
    /// Retrieve the starting end
    func getOneEnd() -> Point3D
    
    /// Retrieve the finishing end
    func getOtherEnd() -> Point3D
    
    /// Change the direction if traversing this curve
    func reverse() -> Void
    
    /// Plot the curve.  Your classic example of polymorphism
    func draw(_ context: CGContext)
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks  
    func resolveNeighbor(_ speck: Point3D) -> (along: Double, perp: Double)
    
}
