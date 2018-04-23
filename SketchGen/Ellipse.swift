//
//  Ellipse.swift
//  SketchCurves
//
//  Created by Paul on 1/26/16.
//  Copyright © 2018 Ceran Digital Media. See LICENSE.md
//

import UIKit

/// An elliptical arc, either whole, or a portion.
/// More of a distorted circle rather than the path of an orbiting body
/// Not ready for prime time!
open class Ellipse: PenCurve {
    
    /// Point around which the ellipse is swept
    /// As contrasted with focii for an orbital ellipse
    fileprivate var ctr: Point3D
    
    /// Length of the major axis
    fileprivate var a: Double
    
    /// Length of the minor axis
    fileprivate var b: Double
    
    /// Orientation (in radians) of the long axis
    fileprivate var azimuth: Double
    
    /// Transform to the global coordinate system
    var toGlobal: Transform
    
    /// Transform to the local coordinate system
    var toLocal: Transform
    
    
    /// Beginning point
    var start: Point3D
    
    /// End point
    var finish: Point3D
    
    /// Angle of the endpoint
    var sweepAngle: Double
    
    /// Whether or not this is closed
    var isFull: Bool
    
    /// Which direction should be swept?
    var isClockwise:  Bool
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    open var parameterRange: ClosedRange<Double>
    
    
    
    /// Basic constructor.  Really needs some input checks!
    /// - Parameters:
    ///   - retnec: Center
    ///   - a: Length of the major axis
    ///   - b: Length of the minor axis
    ///   - azimuth: Angle (radians) of the long axis
    ///   - normal:  Vector perpendicular to the plane of the ellipse
    public init(retnec: Point3D, a: Double, b: Double, azimuth: Double, start: Point3D, finish: Point3D, normal: Vector3D)   {
        
        self.ctr = retnec
        self.a = a
        self.b = b
        self.azimuth = azimuth
        self.start = start
        self.finish = finish
        
        self.isFull = true
        self.isClockwise = true
        
        self.usage = PenTypes.ordinary
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        let horiz = Vector3D.built(from: self.ctr, towards: self.start, unit: true)
        let vert = try! Vector3D.crossProduct(lhs: normal, rhs: horiz)
        
        let localCSYS = try! CoordinateSystem(spot: self.ctr, direction1: horiz, direction2: vert, useFirst: true, verticalRef: false)
        self.toGlobal = Transform.genToGlobal(csys: localCSYS)
        self.toLocal = Transform.genFromGlobal(csys: localCSYS)
        
           // Find the angle of the end point
        let delta = Vector3D.built(from: self.ctr, towards: self.finish)
        self.sweepAngle = acos(delta.i / a)
        
    }
    
    
    /// Attach new meaning to the curve
    open func setIntent(purpose: PenTypes)   {
        
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
    
    /// Find the point along this ellipse specified by the parameter 't'
    /// - Parameters:
    ///   - t:  Curve parameter value.  Assumed 0 < t < 1.
    /// - Returns: Point location at the parameter value
    open func pointAt(t: Double) throws -> Point3D  {
        
        let theta = t * self.sweepAngle
        
        let x = cos(theta) * a
        var y = findY(x: x)
        
        if theta > Double.pi   {
            y *= -1.0
        }
        
        let localSpot = Point3D(x: x, y: y, z: 0.0)
        let spot = Point3D.transform(pip: localSpot, xirtam: self.toGlobal)
        return spot
    }
    
    
    /// This currently returns a useless value
    public func getExtent() -> OrthoVol  {
        
        return try! OrthoVol(corner1: self.start, corner2: self.finish)
    }
    
    
    /// Determine an X value from a given angle (in radians)
    /// - Parameters:
    ///   - ang:  Desired angle (radians)
    /// - Returns: Local X value for the angle
   open func findX(ang: Double) -> Double   {
        
        let base = cos(ang)
        let alongX = base * self.a
        
        return alongX
    }
    
    
    /// Determine a Y value from a given X
    /// - Returns: Y value for the given X
    open func findY(x: Double) -> Double  {
        
        let y = sqrt(b * b * (1 - (x * x) / (a * a)))
        return y
    }
    
    
    /// Move, rotate, and scale by a matrix
    /// This probably doesn't work!
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    open func transform(xirtam: Transform) -> PenCurve {
        
        let tAlpha = Point3D.transform(pip: self.start, xirtam: xirtam)
        let tOmega = Point3D.transform(pip: self.finish, xirtam: xirtam)
        let tCent = Point3D.transform(pip: self.ctr, xirtam: xirtam)
        
        let outward = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let transformed = Ellipse(retnec: tCent, a: self.a, b: self.b, azimuth: self.azimuth, start: tAlpha, finish: tOmega, normal: outward)
        
        transformed.setIntent(purpose: self.usage)   // Copy setting instead of having the default
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
            
            xCG = CGFloat(try! pointAt(t: stepU).x)
            yCG = CGFloat(try! pointAt(t: stepU).y)
  //          print(String(describing: xCG) + "  " + String(describing: yCG))
            
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
    open func resolveRelative(speck: Point3D) -> (along: Double, away: Double)   {
        
        // TODO: Make this return something besides dummy values
        
        return (1.0, 1.0)
    }
    
    
}    // End of definition for class Ellipse


