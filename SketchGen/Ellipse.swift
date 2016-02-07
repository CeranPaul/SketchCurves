//
//  Ellipse.swift
//  SketchCurves
//
//  Created by Paul on 1/26/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import UIKit

/// An elliptical arc, either whole, or a portion. More of a distorted circle rather than the path of an orbiting body
public class Ellipse: PenCurve {
    
    /// Point around which the ellipse is swept
    /// As contrasted with focii for an orbital ellipse
    private var ctr: Point3D
    
    /// Length of the larger axis
    private var a: Double
    
    /// Length of the smaller axis
    private var b: Double
    
    /// Orientation of the long axis
    private var azimuth: Double
    
    
    /// Beginning point as angle in radians
    var start: Point3D
    
    /// End point as angle in radians
    var finish: Point3D
    
    /// Whether or not this is closed
    var isFull: Bool
    
    /// Which direction should be swept?
    var isClockwise:  Bool
    
    /// The enum that hints at the meaning of the curve
    public var usage: PenTypes
    
    /// The box that contains the curve
    /// - Warning:  The class currently has no way to figure a correct and useful value    
    public var extent: OrthoVol
    
    
    public init(retnec: Point3D, a: Double, b: Double, azimuth: Double, start: Point3D, finish: Point3D)   {
        
        self.ctr = retnec
        self.a = a
        self.b = b
        self.azimuth = azimuth
        self.start = start
        self.finish = finish
        
        self.isFull = true
        self.isClockwise = true
        self.usage = PenTypes.Default
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -1.0, maxY: 1.0, minZ: -0.2, maxZ: 0.2)
    }
    
    
    /// Attach new meaning to the curve
    public func setIntent(purpose: PenTypes)   {
        
        self.usage = purpose
    }
    
    /// Simple getter for the center point
    public func getCenter() -> Point3D   {
        return self.ctr
    }
    
    /// Simple getter for the beginning point
    public func getOneEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        
        return self.start
    }
    
    /// Simple getter for the ending point
    public func getOtherEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        
        return self.finish
    }
    
    /// Find the point along this line segment specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    public func pointAt(t: Double) -> Point3D  {
        
        
        // TODO: Make this something besides a cop-out
        
        let spot = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        return spot
    }
    
    /// Determine an X value from a given angle (in radians)
    public func findX(ang: Double) -> Double   {
        
        let base = cos(ang)
        let alongX = base * self.a
        
        return alongX
    }
    
    
    /// Determine a Y value from a given X
    public func findY(x: Double) -> Double  {
        
        let y = sqrt(b * b * (1 - (x * x) / (a * a)))
        return y
    }
    
    /// Plot the elliptical segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext)  {
        
        // TODO: Make this draw an ellipse, not a circle
        
        
        
//        CGContextStrokePath(context)
        
    }
    
    
    /// Change the traversal direction of the curve so it can be aligned with other members of Perimeter
    public func reverse() {
        
        // TODO: Make this something besides a cop-out
        
    }
    
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks
    public func resolveNeighbor(speck: Point3D) -> (along: Double, perp: Double)   {
        
        // TODO: Make this return something besides dummy values
        return (1.0, 0.0)
    }
    
    
}    // End of definition for class Ellipse


