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
open class LineSeg: PenCurve {    // Can this be a struct, instead?
    
    // End points
    fileprivate var endAlpha: Point3D   // Private access to limit modification
    fileprivate var endOmega: Point3D
    
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    /// The box that contains the curve
    open var extent: OrthoVol
    
    
    
    /// Build a line segment from two points
    /// - Throws: CoincidentPointsError
    public init(end1: Point3D, end2: Point3D) throws {
        
        self.endAlpha = end1
        self.endOmega = end2
        
        self.usage = PenTypes.default
        
            // Dummy assignment because of the peculiarities of being an init
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
            // Because this is an 'init', a guard statement cannot be used at the top
        guard (end1 != end2) else { throw CoincidentPointsError(dupePt: end1)}
        
        self.extent = try OrthoVol(corner1: self.endAlpha, corner2: self.endOmega)
        
    }
    
    /// Find the point along this line segment specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    open func pointAt(_ t: Double) -> Point3D  {
        
        let wholeVector = Vector3D.built(self.endAlpha, towards: self.endOmega)
        
        let scaled = wholeVector * t    // Implies that 0 < t < 1
        
        let spot = self.endAlpha.offset(scaled)
        
        return spot
    }
    
    
    /// Attach new meaning to the curve
    open func setIntent(_ purpose: PenTypes)   {
        
        self.usage = purpose
    }
    
    /// Fetch the location of an end
    /// - See: 'getOtherEnd()'
    open func getOneEnd() -> Point3D   {
        return endAlpha
    }
    
    /// Fetch the location of the opposite end
    /// - See: 'getOneEnd()'
    open func getOtherEnd() -> Point3D   {
        return endOmega
    }
    
    /// Flip the order of the end points  Used to align members of a Perimeter
    open func reverse() -> Void  {
        
        let bubble = self.endAlpha
        self.endAlpha = self.endOmega
        self.endOmega = bubble
    }
    
    /// Create a unit vector showing direction
    open func getDirection() -> Vector3D   {
        
        var along = Vector3D.built(self.endAlpha, towards: self.endOmega)
        try! along.normalize()   // The checks in the constructor should make this safe
        
        return along   // I think it's weird that this has to be a separate line
    }
    
    /// Move, rotate, and scale by a matrix
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    open func transform(_ xirtam: Transform) throws -> LineSeg {
        
        let tAlpha = endAlpha.transform(xirtam)
        let tOmega = endOmega.transform(xirtam)
        
        let transformed = try LineSeg(end1: tAlpha, end2: tOmega)   // Will generate a new extent
        transformed.setIntent(self.usage)   // Copy setting instead of having the default
        return transformed
    }
    
    
    /// Find the position of a point relative to the LineSeg
    open func resolveNeighbor(_ speck: Point3D) -> (along: Double, perp: Double)   {
        
        let unitAlong = self.getDirection()
        
        let bridge = Vector3D.built(self.endAlpha, towards: speck)
        
        let lenAlong = Vector3D.dotProduct(unitAlong, rhs: bridge)
        
        let componentAlong = unitAlong * lenAlong
        
        let componentPerp = bridge - componentAlong
        
        return (lenAlong, componentPerp.length())
    }
    
    
    
    /// Plot the line segment.  This will be called by the UIView 'drawRect' function
    open func draw(_ context: CGContext)  {
        
        var xCG: CGFloat = CGFloat(self.endAlpha.x)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.endAlpha.y)
        
        context.move(to: CGPoint(x: xCG, y: yCG))
        
        
        xCG = CGFloat(self.endOmega.x)
        yCG = CGFloat(self.endOmega.y)
        context.addLine(to: CGPoint(x: xCG, y: yCG))
        
        context.strokePath()
    }
    
}
