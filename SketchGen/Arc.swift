//
//  Arc.swift
//  SketchCurves
//
//  Created by Paul on 11/7/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import UIKit

/// A circular arc - either whole, or a portion
/// This DOES NOT handle the case of precisely half a circle
/// - SeeAlso:  Ellipse
public class Arc: PenCurve {
    
    /// Point around which the arc is swept
    private var ctr: Point3D
    
    private var axisDir: Vector3D   // Needs to be a unit vector
    
    /// Beginning point
    private var start: Point3D
    private var finish: Point3D
    
    private var sweepAngle: Double   // Can be either positive or negative
                                     // Magnitude should be less that 2 pi
    
    
    
    /// Derived radius of the Arc
    private var rad: Double
    
    /// Whether or not this is a complete circle
    public var isFull: Bool
    
    /// The enum that hints at the meaning of the curve
    public var usage: PenTypes
    
    /// The box that contains the curve
    public var extent: OrthoVol
    
    
    
    /// The simplest initializer
    public init(center: Point3D, axis: Vector3D, end1: Point3D, sweep: Double) throws   {
        
        self.ctr = center
        self.axisDir = axis
        self.start = end1
        self.sweepAngle = sweep
        
        self.rad = Point3D.dist(self.ctr, pt2: self.start)
        
        self.isFull = false
        if self.sweepAngle == 2.0 * M_PI   { self.isFull = true }
        
        self.usage = PenTypes.Default   // Use 'setIntent' to attach the desired value
        
        // Dummy assignment. Postpone the expensive calculation until after the guard statements
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        // In an 'init', this cannot be done at the top
        guard (!self.axisDir.isZero()) else  {throw ZeroVectorError(dir: self.axisDir)}
        guard (self.axisDir.isUnit()) else  {throw NonUnitDirectionError(dir: self.axisDir)}
        
        guard (self.ctr != self.start)  else  { throw CoincidentPointsError(dupePt: self.start) }
        
            
        var horiz = Vector3D.built(self.ctr, towards: self.start)
        try! horiz.normalize()
            
        let vert = try! Vector3D.crossProduct(self.axisDir, rhs: horiz)
            
        let magnitudeH = self.rad * cos(sweepAngle)
        let deltaH = horiz * magnitudeH
            
        let magnitudeV = self.rad * sin(sweepAngle)
        let deltaV = vert * magnitudeV
            
        let jump = deltaH + deltaV
            
        self.finish = self.ctr.offset(jump)
        
        self.extent = figureExtent()    // Replace the dummy value
        
    }
    
    
    /// Simple getter for the center point
    public func getCenter() -> Point3D   {
        return self.ctr
    }
    
    public func getOneEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        return self.start
    }
    
    public func getOtherEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        return self.finish
    }
    
    public func getRadius() -> Double   {
        return rad
    }
    
    public func getSweepAngle() -> Double   {
        return sweepAngle
    }
    
    /// Attach new meaning to the curve
    public func setIntent(purpose: PenTypes)   {
        self.usage = purpose
    }
    
    
    /// Build an arc from a center and two boundary points
    /// This blows up for a half or full circle
    /// - Throws: CoincidentPointsError, ArcPointsError
    public static func buildFromCenterStartFinish(center: Point3D, end1: Point3D, end2: Point3D, useSmallAngle: Bool) throws -> Arc {
        
        // TODO: Add guard statements for half and full circles
        
        // Check that input points are unique
        guard (end1 != center && end2 != center) else { throw CoincidentPointsError(dupePt: center) }
        guard (end1 != end2) else { throw CoincidentPointsError(dupePt: end1) }
        
        // See if an arc can actually be made from the three given inputs
        guard (Arc.isArcable(center, end1: end1, end2: end2))  else  { throw ArcPointsError(badPtA: center, badPtB: end1, badPtC: end2)  }
        
        
        
        var vecStart = Vector3D.built(center, towards: end1)
        try! vecStart.normalize()
        var vecFinish = Vector3D.built(center, towards: end2)
        try! vecFinish.normalize()
        
        var spin = try! Vector3D.crossProduct(vecStart, rhs: vecFinish)
        try! spin.normalize()
        
        let sweepAngle = Arc.findAngle(vecStart, rhs: vecFinish, perp: spin)
        
        let bow = try Arc(center: center, axis: spin, end1: end1, sweep: sweepAngle)
        
        return bow
    }
    
    
    /// This should become a static function in class Vector3D
    public static func findAngle(lhs: Vector3D, rhs: Vector3D, perp: Vector3D) -> Double   {
        
        let projection = Vector3D.dotProduct(lhs, rhs: rhs)
        var angleRaw = acos(projection)
        
        var vert = try! Vector3D.crossProduct(perp, rhs: lhs)
        try! vert.normalize()
        
        let side = Vector3D.dotProduct(rhs, rhs: vert)
        
        var angle = angleRaw
        
        if side < 0.0   { angle = 2.0 * M_PI - angleRaw  }
        
        
        return angle
    }
    
    /// Determine the range of angles covered by the arc
    /// See the first illustration in the wiki article "Arc Configuration".
    ///  - Warning:  Will blow up with a half circle
    func findRange() -> Double   {
        
        if self.isFull   {  return 2.0 * M_PI  }   // This case should have been avoided by logic in the constructor
            
        else  {
            
            /// Vector from the center towards the start point
            var vecStart = Vector3D.built(self.ctr, towards: self.start)
            try! vecStart.normalize()   // Checks in the constructor should keep this from being zero length
            
            var vecFinish = Vector3D.built(self.ctr, towards: self.finish)
            try! vecFinish.normalize()   // Checks in the constructor should keep this from being zero length
            
            var perp = try! Vector3D.crossProduct(vecStart, rhs: vecFinish)
            try! perp.normalize()
            
               // For Case A in the illustration, perp will be going into the page

            
            let perpToVecStart = try! Vector3D.crossProduct(perp, rhs: vecStart)
            
            
            /// Vector from the start point towards the finish point
            let startFinish = Vector3D.built(self.start, towards: self.finish)
            
            
            // Can range from -1.0 to 1.0, with a void at 0.0
            let sense = Vector3D.dotProduct(perpToVecStart, rhs: startFinish)
            
            var side = true
            side = sense > 0.0
            
            
            let projection = Vector3D.dotProduct(vecStart, rhs: vecFinish)
            
            /// The raw material for determining the range
            let angleRaw = acos(projection)
            
            
            
            /// Value to be returned.  The initial value will be overwritten 50% of the time
            var angle = angleRaw
            
            
            return angle
        }
    }
    
    
    /// Angle should be in radians
    /// Angle is relative to a line between the center and the start point independent of direction of the arc
    /// See the illustration in the wiki "Arc PointAtAngle" article
    /// I'm not sure that this is still needed
    public func pointAtAngle(theta: Double) -> Point3D  {
        
        var horiz = Vector3D.built(self.ctr, towards: self.start)
        try! horiz.normalize()
        
        
        let vert = try! Vector3D.crossProduct(self.axisDir, rhs: horiz)   // Shouldn't need to be normalized
        
        let magnitudeH = self.rad * cos(theta)
        let deltaH = horiz * magnitudeH
        
        let magnitudeV = self.rad * sin(theta)
        let deltaV = vert * magnitudeV
        
        let jump = deltaH + deltaV
        
        return self.ctr.offset(jump)
    }
    
    
    /// Find the point along this arc specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    public func pointAt(t: Double) -> Point3D  {
        
        var deltaAngle = t * self.sweepAngle    // Implies that 0 < t < 1
        
        let spot = pointAtAngle(deltaAngle)
        
        return spot
    }
    
    
    // TODO:  Add a length function
    
    
    /// Plot the arc segment.  This will be called by the UIView 'drawRect' function
    /// Disabled because it only works in the XY plane
    public func draw(context: CGContext)  {
        
        let xCG: CGFloat = CGFloat(self.ctr.x)    // Convert to "CGFloat", and throw out Z coordinate
        let yCG: CGFloat = CGFloat(self.ctr.y)
        
        var dirFlag: Int32 = 1
//        if !self.isClockwise  { dirFlag = 0 }
        
//        CGContextAddArc(context, xCG, yCG, CGFloat(self.rad), CGFloat(self.startAngle), CGFloat(self.finishAngle), dirFlag)
        
        CGContextStrokePath(context)
        
    }
    
    /// Define the smallest aligned rectangle that encloses the arc
    /// Probably returns bad values half of the time in the current state
    func figureExtent() -> OrthoVol  {
        
        let rad = Point3D.dist(self.ctr, pt2: self.start)
        
        var mostY = ctr.y + rad
        var mostX = ctr.x + rad
        var leastY = ctr.y - rad
        var leastX = ctr.x - rad
        
        if !self.isFull   {
            
            var chord = Vector3D.built(start, towards: finish)
            try! chord.normalize()   // Checks in the constructor should keep this from being a zero vector
        
            let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)   // TODO: Make this not so brittle
            var split = try! Vector3D.crossProduct(up, rhs: chord)
            try! split.normalize()   // Checks in the crossProduct should keep this from being a zero vector
        
            var discard = split
//            if self.isClockwise   { discard = split.reverse()  }
        
        
            let north = Point3D(x: ctr.x, y: mostY, z: 0.0)
            let east = Point3D(x: mostX, y: ctr.y, z: 0.0)
            let south = Point3D(x: ctr.x, y: leastY, z: 0.0)
            let west = Point3D(x: leastX, y: ctr.y, z: 0.0)
        
                // Create vectors towards the compass points
            let goNorth = Vector3D.built(start, towards: north)    // These could very well be zero length
            let goEast = Vector3D.built(start, towards: east)
            let goSouth = Vector3D.built(start, towards: south)
            let goWest = Vector3D.built(start, towards: west)
        
        
            let northDot = Vector3D.dotProduct(discard, rhs: goNorth)
            let eastDot = Vector3D.dotProduct(discard, rhs: goEast)
            let southDot = Vector3D.dotProduct(discard, rhs: goSouth)
            let westDot = Vector3D.dotProduct(discard, rhs: goWest)
        
            if northDot > 0.0   { mostY = max(start.y, finish.y) }
            if eastDot > 0.0   { mostX = max(start.x, finish.x) }
            if southDot > 0.0   { leastY = min(start.y, finish.y) }
            if westDot > 0.0   { leastX = min(start.x, finish.x) }
        }
        
        return OrthoVol(minX: leastX, maxX: mostX, minY: leastY, maxY: mostY, minZ: -1 * rad / 10.0, maxZ: rad / 10.0)
    }
    
    /// Build the center of a circle from three points on the perimeter
    public static func findCenter(larry: Point3D, curly: Point3D, moe: Point3D) throws -> Point3D   {
        
        guard(Point3D.isThreeUnique(larry, beta: curly, gamma: moe))  else  { throw ArcPointsError(badPtA: larry, badPtB: curly, badPtC: moe) }
        
        
        /// The desired result to be returned
        var ctr = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        var vecA = Vector3D.built(larry, towards: curly)
        try! vecA.normalize()   // The guard statement above should keep this from being a zero vector
        
        var vecB = Vector3D.built(curly, towards: moe)
        try! vecB.normalize()   // The guard statement above should keep this from being a zero vector
        
        var axle = try! Vector3D.crossProduct(vecA, rhs: vecB)   // The guard statement above should keep these from being zero vectors
        try! axle.normalize()   // The crossProduct function should keep this from being a zero vector
        
        let midA = Point3D.midway(larry, beta: curly)
        var perpA = try! Vector3D.crossProduct(vecA, rhs: axle)
        try! perpA.normalize()   // The crossProduct function should keep this from being a zero vector
        
        let midB = Point3D.midway(curly, beta: moe)
        var perpB = try! Vector3D.crossProduct(vecB, rhs: axle)
        try! perpB.normalize()   // The crossProduct function should keep this from being a zero vector
        
        
        do   {
            
            let pLineA = try Line(spot: midA, arrow: perpA)
            let pLineB = try Line(spot: midB, arrow: perpB)
            
            ctr = try Line.intersectTwo(pLineA, straightB: pLineB)
            
        }  catch  {
            print("Finding the circle center didn't work out.")
        }
        
        return ctr
    }
    
    /// Check three points to see if they fit the pattern for defining an Arc
    public static func isArcable(center: Point3D, end1: Point3D, end2: Point3D) -> Bool  {
        
        if !Point3D.isThreeUnique(center, beta: end1, gamma: end2)  { return false }
        
        let dist1 = Point3D.dist(center, pt2: end1)
        let dist2 = Point3D.dist(center, pt2: end2)
        
        let thumbsUp = abs(dist1 - dist2) < Point3D.Epsilon
        
        return thumbsUp
    }
    
    /// Change the traversal direction of the curve so it can be aligned with other members of Perimeter
    public func reverse() {
        
        let bubble = self.start
        self.start = self.finish
        self.finish = bubble
        self.sweepAngle = -1.0 * self.sweepAngle
        
    }
    
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks
    /// Not implemented
    public func resolveNeighbor(speck: Point3D) -> (along: Double, perp: Double)   {
        
        // TODO: Make this return something besides dummy values
        return (1.0, 0.0)
    }
    
    /// Check for two having the same center point
    /// - Parameter: lhs: One Arc
    /// - Parameter: rhs: Another Arc
    /// - SeeAlso:  Overloaded ==
    public static func isConcentric(lhs: Arc, rhs: Arc) -> Bool  {
        
        let flag = lhs.ctr == rhs.ctr

        return flag
    }
    
    // TODO: Write a check for two having the same centerline.  Or does that go with a cylinder?
    
    
}    // End of definition for class Arc


/// Check to see that both are built from the same points
/// Should this be modified to include the complementary definition?
/// - SeeAlso:  Arc.isConcentric
public func == (lhs: Arc, rhs: Arc) -> Bool   {
    
    let ctrFlag = lhs.ctr == rhs.ctr
    let startFlag = lhs.start == rhs.start
    let sweepFlag = lhs.sweepAngle == rhs.sweepAngle
    let axisFlag = lhs.axisDir == rhs.axisDir
    
    return ctrFlag && startFlag && sweepFlag && axisFlag
}

