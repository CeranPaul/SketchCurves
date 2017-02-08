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
open class Arc: PenCurve {
    
    /// Point around which the arc is swept
    fileprivate var ctr: Point3D
    
    fileprivate var axisDir: Vector3D   // Needs to be a unit vector
    
    /// Beginning point
    fileprivate var start: Point3D
    fileprivate var finish: Point3D
    
    fileprivate var sweepAngle: Double   // Can be either positive or negative
                                     // Magnitude should be less that 2 pi
    
    
    
    /// Derived radius of the Arc
    fileprivate var rad: Double
    
    /// Whether or not this is a complete circle
    open var isFull: Bool
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    /// The box that contains the curve
    open var extent: OrthoVol
    
    
    
    /// The simplest initializer
    public init(center: Point3D, axis: Vector3D, end1: Point3D, sweep: Double) throws   {
        
        self.ctr = center
        self.axisDir = axis
        self.start = end1
        self.sweepAngle = sweep
        
        self.rad = Point3D.dist(self.ctr, pt2: self.start)
        
        self.isFull = false
        if self.sweepAngle == 2.0 * M_PI   { self.isFull = true }
        
        
        self.usage = PenTypes.default   // Use 'setIntent' to attach the desired value
        
        // Dummy assignment. Postpone the expensive calculation until after the guard statements
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        // In an 'init', this cannot be done at the top
        guard (!self.axisDir.isZero()) else  {throw ZeroVectorError(dir: self.axisDir)}
        guard (self.axisDir.isUnit()) else  {throw NonUnitDirectionError(dir: self.axisDir)}
        
        guard (self.ctr != self.start)  else  { throw CoincidentPointsError(dupePt: self.start)}
        
            
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
    open func getCenter() -> Point3D   {
        return self.ctr
    }
    
    open func getOneEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        return self.start
    }
    
    open func getOtherEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        return self.finish
    }
    
    open func getRadius() -> Double   {
        return rad
    }
    
    open func getAxisDir() -> Vector3D   {
        return axisDir
    }
    
    open func getSweepAngle() -> Double   {
        return sweepAngle
    }
    
    /// Attach new meaning to the curve
    open func setIntent(_ purpose: PenTypes)   {
        self.usage = purpose
    }
    
    
    /// Build an arc from a center and two boundary points
    /// This blows up for a half or full circle
    /// - Throws: CoincidentPointsError, ArcPointsError
    open static func buildFromCenterStartFinish(_ center: Point3D, end1: Point3D, end2: Point3D, useSmallAngle: Bool) throws -> Arc {
        
        // TODO: Add guard statements for half and full circles
        
        // Check that input points are unique  Can these be replaced by a call to 'isThreeUnique'?
        guard (end1 != center && end2 != center) else { throw CoincidentPointsError(dupePt: center)}
        guard (end1 != end2) else { throw CoincidentPointsError(dupePt: end1)}
        
        // See if an arc can actually be made from the three given inputs
        guard (Arc.isArcable(center, end1: end1, end2: end2))  else  { throw ArcPointsError(badPtA: center, badPtB: end1, badPtC: end2)}
        
        
        
        var vecStart = Vector3D.built(center, towards: end1)
        try! vecStart.normalize()
        var vecFinish = Vector3D.built(center, towards: end2)
        try! vecFinish.normalize()
        
        var spin = try! Vector3D.crossProduct(vecStart, rhs: vecFinish)
        try! spin.normalize()
        
        let rawAngle = try! Vector3D.findAngle(vecStart, measureTo: vecFinish, perp: spin)
        
        var sweepAngle = rawAngle
        if !useSmallAngle   { sweepAngle = rawAngle - 2.0 * M_PI  }
        
        let bow = try Arc(center: center, axis: spin, end1: end1, sweep: sweepAngle)
        
        return bow
    }
    
    
    /// Angle is relative to a line between the center and the start point independent of direction of the arc
    /// - Parameter: theta: Angle in radians
    /// See the illustration in the wiki "Arc PointAtAngle" article
    open func pointAtAngle(_ theta: Double) -> Point3D  {
        
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
    open func pointAt(_ t: Double) -> Point3D  {
        
        let deltaAngle = t * self.sweepAngle    // Implies that 0 < t < 1
        
        let spot = pointAtAngle(deltaAngle)
        
        return spot
    }
    
    
    // TODO:  Add a length function
    
    
    /// Change the traversal direction of the curve so it can be aligned with other members of Perimeter
    open func reverse() {
        
        let bubble = self.start
        self.start = self.finish
        self.finish = bubble
        self.sweepAngle = -1.0 * self.sweepAngle
    }
    
    
    /// Check three points to see if they fit the pattern for defining an Arc
    /// - Parameter: center: Point3D used for pivoting
    /// - Parameter: end1: Point3D on the perimeter
    /// - Parameter: end2: Point3D on the perimeter
    open static func isArcable(_ center: Point3D, end1: Point3D, end2: Point3D) -> Bool  {
        
        if !Point3D.isThreeUnique(center, beta: end1, gamma: end2)  { return false }
        
        let dist1 = Point3D.dist(center, pt2: end1)
        let dist2 = Point3D.dist(center, pt2: end2)
        
        let thumbsUp = abs(dist1 - dist2) < Point3D.Epsilon
        
        return thumbsUp
    }
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks
    /// Not implemented
    open func resolveNeighbor(_ speck: Point3D) -> (along: Double, perp: Double)   {
        
        // TODO: Make this return something besides dummy values
        return (1.0, 0.0)
    }
    
    /// Plot the arc segment.  This will be called by the UIView 'drawRect' function
    /// Disabled because it only works in the XY plane
    open func draw(_ context: CGContext)  {
        
        let xCG: CGFloat = CGFloat(self.ctr.x)    // Convert to "CGFloat", and throw out Z coordinate
        let yCG: CGFloat = CGFloat(self.ctr.y)
        
        var dirFlag: Int32 = 1
//        if !self.isClockwise  { dirFlag = 0 }
        
//        CGContextAddArc(context, xCG, yCG, CGFloat(self.rad), CGFloat(self.startAngle), CGFloat(self.finishAngle), dirFlag)
        
        context.strokePath()
        
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
    
    
    /// Build the center of a circle from three points on the perimeter
    /// - Throws: ArcPointsError if there any coincident points in the inputs
    open static func findCenter(_ larry: Point3D, curly: Point3D, moe: Point3D) throws -> Point3D   {
        
        guard(Point3D.isThreeUnique(larry, beta: curly, gamma: moe))  else  { throw ArcPointsError(badPtA: larry, badPtB: curly, badPtC: moe)}
        
        
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
    
    /// Check for two having the same center point and axis
    /// - Parameter: lhs: One Arc
    /// - Parameter: rhs: Another Arc
    /// - SeeAlso:  Overloaded ==
    open static func isConcentric(_ lhs: Arc, rhs: Arc) -> Bool  {
        
        let ctrFlag = lhs.ctr == rhs.ctr
        
        let axisFlag1 = lhs.getAxisDir() == rhs.getAxisDir()
        let axisFlag2 = Vector3D.isOpposite(lhs.getAxisDir(), rhs: rhs.getAxisDir())
        let axisFlag = axisFlag1 || axisFlag2
        
        return ctrFlag && axisFlag
    }
    
    
    
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

