//
//  PenCurve.swift
//  SketchCurves
//
//  Created by Paul on 10/30/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

public protocol PenCurve   {
    
    /// The enum that hints at the meaning of the curve
    var usage: PenTypes   { get set }
    
    var parameterRange: ClosedRange<Double>   { get set }
    
    /// Supply the point on the curve for the input parameter value
    func pointAt(t: Double) throws -> Point3D
    
    /// Retrieve the starting end
    func getOneEnd() -> Point3D
    
    /// Retrieve the finishing end
    func getOtherEnd() -> Point3D
    
    /// Change the direction in-place.  Useful for traversing a Perimeter
    func reverse() -> Void
    
    /// Transform with a 4 x 4 matrix, not a CGAffineTransform
    func transform(xirtam: Transform) throws -> PenCurve
    
    /// Figure the volume that encloses the curve
    /// Must have finite thickness in all three axes
    func getExtent() -> OrthoVol
    
    /// Plot the curve.  Your classic example of polymorphism
    /// - SeeAlso:  drawControls() for a Cubic
    func draw(context: CGContext, tform: CGAffineTransform)
    
       // getLength and intersect are near-term candidates for additional funcs
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks  
    func resolveRelative(speck: Point3D) -> (along: Vector3D, perp: Vector3D)
    
}
