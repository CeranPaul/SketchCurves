//
//  Ellipse.swift
//  SketchCurves
//
//  Created by Paul on 1/26/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import UIKit

/// An elliptical arc, either whole, or a portion.  As opposed to the path of an orbiting body
public class Ellipse: PenCurve {
    
    /// Point around which the arc is swept
    private var ctr: Point3D
    
    /// Beginning point
    var start: Point3D
    
    /// End point
    var finish: Point3D
    
    /// Whether or not this is a complete circle
    var isFull: Bool
    
    /// Which direction should be swept?
    var isClockwise:  Bool
    
    /// The enum that hints at the meaning of the curve
    public var usage: PenTypes
    
    /// The box that contains the curve
    public var extent: OrthoVol
    
    
    init()   {
        
        ctr = Point3D(x: 0.0, y: 0.0, z: 0.0)
        start = Point3D(x: -0.5, y: 0.0, z: 0.0)
        finish = Point3D(x: 0.5, y: 0.0, z: 0.0)
        isFull = true
        isClockwise = true
        usage = PenTypes.Default
        extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -1.0, maxY: 1.0, minZ: -0.2, maxZ: 0.2)
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
        return start
    }
    
    /// Simple getter for the ending point
    public func getOtherEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        return finish
    }
    
    /// Find the point along this line segment specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    public func pointAt(t: Double) -> Point3D  {
        
        
        // TODO: Make this something besides a cop-out
        
        let spot = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        return spot
    }
    
    
    /// Plot the elliptical segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext)  {
        
        // TODO: Make this draw an ellipse, not a circle
        
        let xCG: CGFloat = CGFloat(self.ctr.x)    // Convert to "CGFloat", and throw out Z coordinate
        let yCG: CGFloat = CGFloat(self.ctr.y)
        
        var dirFlag: Int32 = 1
        if !self.isClockwise  { dirFlag = 0 }
        
        CGContextAddArc(context, xCG, yCG, CGFloat(0.5), CGFloat(-M_PI), CGFloat(0.0), dirFlag)
        
        CGContextStrokePath(context)
        
    }
    
    
    /// Change the traversal direction of the curve so it can be aligned with other members of Perimeter
    public func reverse() {
        
        // TODO: Make this something besides a cop-out
        
    }
    
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks
    public func resolveBridge(speck: Point3D) -> (along: Double, perp: Double)   {
        
        // TODO: Make this return something besides dummy values
        return (1.0, 0.0)
    }
    
    
}    // End of definition for struct Arc


