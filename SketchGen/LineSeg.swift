//
//  LineSeg.swift
//  SketchCurves
//
//  Created by Paul on 10/28/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
//import simd
import UIKit

/// A wire between two points
public class LineSeg: PenCurve {    // Can this be a struct, instead?
    
    // End points
    private var endAlpha: Point3D   // Private access to limit modification
    private var endOmega: Point3D
    
    
    /// The enum that hints at the meaning of the curve
    public var usage: PenTypes
    
    /// The box that contains the curve
    public var extent: OrthoVol
    
    
    
    /// Build a line segment from two points
    /// - Throws: CoincidentPointsError
    public init(end1: Point3D, end2: Point3D) throws {
        
        self.endAlpha = end1
        self.endOmega = end2
        
        self.usage = PenTypes.Default
        
            // Dummy assignment because of the peculiarities of being an init
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
            // Because this is an 'init', a guard statement cannot be used at the top
        guard (end1 != end2) else { throw CoincidentPointsError(dupePt: end1) }
        
        self.extent = try OrthoVol(corner1: self.endAlpha, corner2: self.endOmega)
        
    }
    
    /// Find the point along this line segment specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    public func pointAt(t: Double) -> Point3D  {
        
        let wholeVector = Vector3D.built(self.endAlpha, towards: self.endOmega)
        
        let scaled = wholeVector * t    // Implies that 0 < t < 1
        
        let spot = self.endAlpha.offset(scaled)
        
        return spot
    }
    
    
    /// Attach new meaning to the curve
    public func setIntent(purpose: PenTypes)   {
        
        self.usage = purpose
    }
    
    /// Fetch the location of an end
    /// - See: 'getOtherEnd()'
    public func getOneEnd() -> Point3D   {
        return endAlpha
    }
    
    /// Fetch the location of the opposite end
    /// - See: 'getOneEnd()'
    public func getOtherEnd() -> Point3D   {
        return endOmega
    }
    
    /// Flip the order of the end points  Used to align members of a Perimeter
    public func reverse() -> Void  {
        
        let bubble = self.endAlpha
        self.endAlpha = self.endOmega
        self.endOmega = bubble
    }
    
    /// Create a unit vector showing direction
    public func getDirection() -> Vector3D   {
        
        var along = Vector3D.built(self.endAlpha, towards: self.endOmega)
        along.normalize()
        
        return along   // I think it's weird that this has to be a separate line
    }
    
    /// Move, rotate, and scale by a matrix
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    public func transform(xirtam: Transform) throws -> LineSeg {
        
        let tAlpha = endAlpha.transform(xirtam)
        let tOmega = endOmega.transform(xirtam)
        
        let transformed = try LineSeg(end1: tAlpha, end2: tOmega)   // Will generate a new extent
        transformed.setIntent(self.usage)   // Copy setting instead of having the default
        return transformed
    }
    
    
    /// Find the position of a point relative to the LineSeg
    public func resolveNeighbor(speck: Point3D) -> (along: Double, perp: Double)   {
        
        var unitAlong = Vector3D.built(self.endAlpha, towards: self.endOmega)
        unitAlong.normalize()
        
        let bridge = Vector3D.built(self.endAlpha, towards: speck)
        
        let lenAlong = Vector3D.dotProduct(unitAlong, rhs: bridge)
        
        let componentAlong = unitAlong * lenAlong
        
        let componentPerp = bridge - componentAlong
        
        return (lenAlong, componentPerp.length())
    }
    
    
    
    /// Plot the line segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext)  {
        
        var xCG: CGFloat = CGFloat(self.endAlpha.x)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.endAlpha.y)
        
        CGContextMoveToPoint(context, xCG, yCG)
        
        
        xCG = CGFloat(self.endOmega.x)
        yCG = CGFloat(self.endOmega.y)
        CGContextAddLineToPoint(context, xCG, yCG)
        
        CGContextStrokePath(context)
    }
    
}
