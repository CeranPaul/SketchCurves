//
//  LineSeg.swift
//  SketchCurves
//
//  Created by Paul on 10/28/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

/// A wire between two points
public class LineSeg: PenCurve {    // Can this be a struct, instead?
    
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
        
        self.usage = PenTypes.ordinary
        
            // Dummy assignment because of the peculiarities of being an init
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
            // Because this is an 'init', a guard statement cannot be used at the top
        guard (end1 != end2) else { throw CoincidentPointsError(dupePt: end1)}
        
        self.extent = try OrthoVol(corner1: self.endAlpha, corner2: self.endOmega)
        
    }
    
    /// Find the point along this line segment specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    open func pointAt(t: Double) -> Point3D  {
        
        let wholeVector = Vector3D.built(from: self.endAlpha, towards: self.endOmega)
        
        let scaled = wholeVector * t    // Implies that 0 < t < 1
        
        let spot = self.endAlpha.offset(jump: scaled)
        
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
    
    /// Calculate the crown over a small segment
    public func findCrown(smallerT: Double, largerT: Double) -> Double   {
        return 0.0
    }
    
    /// Create a unit vector showing direction
    /// - Returns: Normalized vector
    open func getDirection() -> Vector3D   {
        
        var along = Vector3D.built(from: self.endAlpha, towards: self.endOmega)
        try! along.normalize()   // The checks in the constructor should make this safe
        
        return along   // I think it's weird that this has to be a separate line
    }
    
    /// Return the tangent vector, which won't depend on the input parameter
    /// Some notations show "t" as the parameter, instead of "u"
    /// - Returns:
    ///   - tan:  Non-normalized vector
    /// Consider making this a member variable
    public func tangentAt(t: Double) -> Vector3D   {
        
        let along = Vector3D.built(from: self.endAlpha, towards: self.endOmega)
        return along
    }
    
    /// Calculate length
    func getLength() -> Double   {
        return Point3D.dist(pt1: self.endAlpha, pt2: self.endOmega)
    }
    
    /// Move, rotate, and scale by a matrix
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    public func transform(xirtam: Transform) throws -> PenCurve {
        
        let tAlpha = endAlpha.transform(xirtam: xirtam)
        let tOmega = endOmega.transform(xirtam: xirtam)
        
        let transformed = try LineSeg(end1: tAlpha, end2: tOmega)   // Will generate a new extent
        transformed.setIntent(self.usage)   // Copy setting instead of having the default
        return transformed
    }
    
    
    /// Find the position of a point relative to the LineSeg
    /// - Returns: Pair of vectors - one along the seg, other perp to it
    public func resolveNeighbor(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
        /// Direction of the segment.  Is a unit vector.
        let thisWay = self.getDirection()
        
        let bridge = Vector3D.built(from: self.endAlpha, towards: speck)
        
        let along = Vector3D.dotProduct(lhs: bridge, rhs: thisWay)
        let alongVector = thisWay * along
        let perpVector = bridge - alongVector
        
        return (alongVector, perpVector)
    }
    
    /// Build a parallel line towards the inside
    /// - Parameters:
    ///   - inset:  Distance desired for the offset
    ///   - stbdIn:  Whether starboard represents "in"
    ///   - upward:  Unit vector perpendicular to the plane of the Perimeter
    /// - Returns: A Line, not a LineSeg
    /// - Warning:  Does not have a Unit Test
    func insetLine(inset: Double, stbdIn: Bool, upward: Vector3D) -> Line   {
        
        let thataway = self.getDirection()
        
        /// Across the segment
        var trans = try! Vector3D.crossProduct(lhs: thataway, rhs: upward)
        try! trans.normalize()
        
        /// Vector going towards the inside
        var inward = trans
        
        if !stbdIn   {
            inward = trans.reverse()
        }
        
        let jump = inward * inset
        let freshOrigin = self.endAlpha.offset(jump: jump)
        
        let arrow = try! Line(spot: freshOrigin, arrow: thataway)
        
        return arrow
    }
    
    
    /// Create a trimmed version
    /// - Parameters:
    ///   - stub:  New terminating point
    ///   - keepNear: Retain the near or far remnant?
    /// - Warning:  No checks are made to see that stub lies on the segment
    /// - Returns: A new LineSeg
    /// - Warning:  Not tested!
    public func clipTo(stub: Point3D, keepNear: Bool) -> LineSeg   {
        
        var freshSeg: LineSeg
        
        if keepNear   {
            freshSeg = try! LineSeg(end1: self.getOneEnd(), end2: stub)
        }  else  {
            freshSeg = try! LineSeg(end1: stub, end2: self.getOtherEnd())
        }
        
        return freshSeg
    }
    
    /// Get the bounding box
    public func getExtent() -> OrthoVol  {
        
        return try! OrthoVol(corner1: self.endAlpha, corner2: self.endOmega)
    }
    
    /// Find possible intersection points with a line
    /// - Parameters:
    ///   - ray:  The Line to be used for intersecting
    ///   - accuracy:  How close is close enough?
    /// - Returns: Array of points common to both curves
    public func intersect(ray: Line, accuracy: Double = Point3D.Epsilon) -> [Point3D] {
        
        /// The return array
        var crossings = [Point3D]()
        
        /// Line built from this segment
        let unbounded = try! Line(spot: self.getOneEnd(), arrow: self.getDirection())
        
        if Line.isParallel(straightA: unbounded, straightB: ray)   {   // Deal with parallel lines
            
            if Line.isCoincident(straightA: unbounded, straightB: ray)   {   // Coincident lines
                
                crossings.append(self.getOneEnd())
                crossings.append(self.getOtherEnd())
                
            }
            
        }  else  {   // Not parallel lines
            
            /// Intersection of the two lines
            let collision = try! Line.intersectTwo(straightA: unbounded, straightB: ray)
            
            /// Vector from segment origin towards intersection
            var rescue = Vector3D.built(from: self.getOneEnd(), towards: collision)
            try! rescue.normalize()
            
            let sameDir = Vector3D.dotProduct(lhs: self.getDirection(), rhs: rescue)
            
            if sameDir > 0.0   {
                
                let dist = Point3D.dist(pt1: self.getOneEnd(), pt2: collision)
                
                if dist <= self.getLength()   {
                    
                    crossings.append(collision)
                }
            }
        }
        
        return crossings
    }
    
    
    /// See if another segment crosses this one
    /// Used for seeing if a screen gesture cuts across the current seg
    /// Unit tests would be good!
    public func isCrossing(chop: LineSeg) -> Bool   {
        
        let compsA = self.resolveNeighbor(speck: chop.endAlpha)
        let compsB = self.resolveNeighbor(speck: chop.endOmega)
        
           // Should be negative if ends are on opposite sides
        let compliance = Vector3D.dotProduct(lhs: compsA.perp, rhs: compsB.perp)
        
        let flag1 = compliance < 0.0
        
        let farthest = self.getLength()
        
        let flag2A = compsA.along.length() <= farthest
        let flag2B = compsB.along.length() <= farthest
        
        return flag1 && flag2A && flag2B
    }
    
    /// Find the change in parameter that meets the crown requirement
    /// - Parameters:
    ///   - allowableCrown:  Acceptable deviation from curve
    ///   - currentT:  Present value of the driving parameter
    ///   - increasing:  Whether the change in parameter should be up or down
    /// - Returns: New value for driving parameter
    public func findStep(allowableCrown: Double, currentT: Double, increasing: Bool) -> Double   {
        
        var trialT : Double
        
        if increasing   {
            trialT = 1.0
        }  else  {
            trialT = 0.0
        }
        
        return trialT
    }
    

    /// Plot the line segment.  This will be called by the UIView 'drawRect' function
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    public func draw(context: CGContext, tform: CGAffineTransform)  {
        
        context.beginPath()
        
        var spot = CGPoint(x: self.endAlpha.x, y: self.endAlpha.y)    // Throw out Z coordinate
        var screenSpot = spot.applying(tform)
        context.move(to: screenSpot)
        
        spot = CGPoint(x: self.endOmega.x, y: self.endOmega.y)    // Throw out Z coordinate
        screenSpot = spot.applying(tform)
        context.addLine(to: screenSpot)
        
        context.strokePath()
    }
    
    
}
