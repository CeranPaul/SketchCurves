//
//  Ellipse.swift
//  SketchCurves
//
//  Created by Paul on 1/26/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

/// An elliptical arc, either whole, or a portion. More of a distorted circle rather than the path of an orbiting body
open class Ellipse: PenCurve {
    
    /// Point around which the ellipse is swept
    /// As contrasted with focii for an orbital ellipse
    fileprivate var ctr: Point3D
    
    /// Length of the larger axis
    fileprivate var a: Double
    
    /// Length of the smaller axis
    fileprivate var b: Double
    
    /// Orientation of the long axis
    fileprivate var azimuth: Double
    
    
    /// Beginning point as angle in radians
    var start: Point3D
    
    /// End point as angle in radians
    var finish: Point3D
    
    /// Whether or not this is closed
    var isFull: Bool
    
    /// Which direction should be swept?
    var isClockwise:  Bool
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    
    public init(retnec: Point3D, a: Double, b: Double, azimuth: Double, start: Point3D, finish: Point3D)   {
        
        self.ctr = retnec
        self.a = a
        self.b = b
        self.azimuth = azimuth
        self.start = start
        self.finish = finish
        
        self.isFull = true
        self.isClockwise = true
        self.usage = PenTypes.ordinary
    }
    
    
    /// Attach new meaning to the curve
    open func setIntent(_ purpose: PenTypes)   {
        
        self.usage = purpose
    }
    
    /// Simple getter for the center point
    open func getCenter() -> Point3D   {
        return self.ctr
    }
    
    /// Simple getter for the beginning point
    open func getOneEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        
        return self.start
    }
    
    /// Simple getter for the ending point
    open func getOtherEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        
        return self.finish
    }
    
    /// Find the point along this line segment specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    open func pointAt(t: Double) -> Point3D  {
        
        
        // TODO: Make this something besides a cop-out
        
        let spot = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        return spot
    }
    
    /// This currently returns a useless value
    public func getExtent() -> OrthoVol  {
        
        return try! OrthoVol(corner1: self.start, corner2: self.finish)
    }
    
    /// Determine an X value from a given angle (in radians)
    open func findX(_ ang: Double) -> Double   {
        
        let base = cos(ang)
        let alongX = base * self.a
        
        return alongX
    }
    
    
    /// Determine a Y value from a given X
    open func findY(_ x: Double) -> Double  {
        
        let y = sqrt(b * b * (1 - (x * x) / (a * a)))
        return y
    }
    
    /// Move, rotate, and scale by a matrix
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    open func transform(xirtam: Transform) -> PenCurve {
        
        let tAlpha = self.start.transform(xirtam: xirtam)
        let tOmega = self.finish.transform(xirtam: xirtam)
        let tCent = self.ctr.transform(xirtam: xirtam)
        
        let transformed = Ellipse(retnec: tCent, a: self.a, b: self.b, azimuth: self.azimuth, start: tAlpha, finish: tOmega)
        
        transformed.setIntent(self.usage)   // Copy setting instead of having the default
        return transformed
    }
    
    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext, tform: CGAffineTransform)  {
        
        var xCG: CGFloat = CGFloat(self.start.x)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.start.y)
        
        let startModel = CGPoint(x: xCG, y: yCG)
        let screenStart = startModel.applying(tform)
        
        context.move(to: screenStart)
        
        
        for g in 1...20   {
            
            let stepU = Double(g) * 0.05   // Gee, this is brittle!
            xCG = CGFloat(pointAt(t: stepU).x)
            yCG = CGFloat(pointAt(t: stepU).y)
            //            print(String(describing: xCG) + "  " + String(describing: yCG))
            let midPoint = CGPoint(x: xCG, y: yCG)
            let midScreen = midPoint.applying(tform)
            context.addLine(to: midScreen)
        }
        
        context.strokePath()
        
    }
    
    
    
    /// Change the traversal direction of the curve so it can be aligned with other members of Perimeter
    open func reverse() {
        
        // TODO: Make this something besides a cop-out
        
    }
    
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks
    open func resolveRelative(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
        // TODO: Make this return something besides dummy values
//        let otherSpeck = speck
        let alongVector = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let perpVector = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        return (alongVector, perpVector)
    }
    
    
}    // End of definition for class Ellipse


