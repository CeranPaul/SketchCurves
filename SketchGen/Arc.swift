//
//  Arc.swift
//  SketchCurves
//
//  Created by Paul on 11/7/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

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
                                         // Should this become a measurement?
    
    
    
    /// Derived radius of the Arc
    fileprivate var rad: Double
    
    /// Whether or not this is a complete circle
    open var isFull: Bool
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    /// The box that contains the curve
    open var extent: OrthoVol
    
    
    
    /// The simplest initializer
    /// - Parameters:
    ///   - center: Point3D used for pivoting
    ///   - axis: Unit vector, often in the +Z direction
    ///   - end1: Starting point
    ///   - sweep: Angle (in radians).  Can be positive or negative
    /// - Throws: ZeroVectorError, NonUnitDirectionError, CoincidentPointsError
    /// This doesn't catch the case of a bad axis direction
    public init(center: Point3D, axis: Vector3D, end1: Point3D, sweep: Double) throws   {
        
        self.ctr = center
        self.axisDir = axis
        self.start = end1
        self.sweepAngle = sweep
        
        self.rad = Point3D.dist(pt1: self.ctr, pt2: self.start)
        
        self.isFull = false
        if self.sweepAngle == 2.0 * M_PI   { self.isFull = true }
        
        self.usage = PenTypes.ordinary   // Use 'setIntent' to attach the desired value
        
        // Dummy assignment. Postpone the expensive calculation until after the guard statements
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        // In an 'init', this cannot be done at the top
        guard (!self.axisDir.isZero()) else  {throw ZeroVectorError(dir: self.axisDir)}
        guard (self.axisDir.isUnit()) else  {throw NonUnitDirectionError(dir: self.axisDir)}
        
        guard (self.ctr != self.start)  else  { throw CoincidentPointsError(dupePt: self.start)}
        
            
        var horiz = Vector3D.built(from: self.ctr, towards: self.start)
        try! horiz.normalize()   // The guard statement should keep this from being a zero vector
        
             // Check the dot product of this and the axis?
        
        /// A vector perpendicular to horiz in the plane of the circle
        let vert = try! Vector3D.crossProduct(lhs: self.axisDir, rhs: horiz)
            
        let magnitudeH = self.rad * cos(sweepAngle)
        let deltaH = horiz * magnitudeH
            
        let magnitudeV = self.rad * sin(sweepAngle)
        let deltaV = vert * magnitudeV
            
        let jump = deltaH + deltaV
            
        self.finish = self.ctr.offset(jump: jump)
        
        
        self.extent = figureExtent()    // Replace the dummy value
        
    }
    
    
    /// Build an arc from a center and two terminating points - perhaps tangent points
    /// Direction is derived from the ordering of end1 and end2
    /// Will fail for a half or full circle
    /// - Parameters:
    ///   - center: Point3D used for pivoting
    ///   - end1: Point3D on the perimeter
    ///   - end2: Point3D on the perimeter
    /// - Throws: ArcPointsError
    public init(center: Point3D, end1: Point3D, end2: Point3D, useSmallAngle: Bool) throws   {
        
        self.ctr = center
        self.start = end1
        self.finish = end2
        
        self.rad = Point3D.dist(pt1: self.ctr, pt2: self.start)
        
        var vecStart = Vector3D.built(from: center, towards: end1)
        try! vecStart.normalize()
        var vecFinish = Vector3D.built(from: center, towards: end2)
        try! vecFinish.normalize()
        
        var spin = try! Vector3D.crossProduct(lhs: vecStart, rhs: vecFinish)   // The guard statement should keep this from failing
        try! spin.normalize()
        
        self.axisDir = spin
        
        self.usage = PenTypes.ordinary   // Use 'setIntent' to attach the desired value
        
        // Dummy assignment. Postpone the expensive calculation until after the guard statements
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        self.isFull = false
        
        self.sweepAngle = 0.0   // Dummy value
        
        
        self.sweepAngle = findRange(useSmallAngle: useSmallAngle)
        
        // See if an arc can actually be made from the three given inputs
        guard (Arc.isArcable(center: center, end1: end1, end2: end2))  else  { throw ArcPointsError(badPtA: center, badPtB: end1, badPtC: end2)}
        
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
    open func setIntent(purpose: PenTypes)   {
        self.usage = purpose
    }
    
    
    
    
    /// Angle is relative to a line between the center and the start point independent of direction of the arc
    /// - Parameter: theta: Angle in radians from the positive X axis
    /// See the illustration in the wiki "Arc PointAtAngle" article
    open func pointAtAngle(theta: Double) -> Point3D  {
        
        var horiz = Vector3D.built(from: self.ctr, towards: self.start)
        try! horiz.normalize()
        
        
        let vert = try! Vector3D.crossProduct(lhs: self.axisDir, rhs: horiz)   // Shouldn't need to be normalized
        
        let magnitudeH = self.rad * cos(theta)
        let deltaH = horiz * magnitudeH
        
        let magnitudeV = self.rad * sin(theta)
        let deltaV = vert * magnitudeV
        
        let jump = deltaH + deltaV
        
        return self.ctr.offset(jump: jump)
    }
    
    
    /// Find the point along this arc specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    /// - Returns: Point
    open func pointAt(t: Double) -> Point3D  {
        
        let horzRef = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        var vecStart = Vector3D.built(from: self.ctr, towards: self.start)
        try! vecStart.normalize()
        
        let startAngle = try! Vector3D.findAngle(baselineVec: horzRef, measureTo: vecStart, perp: self.axisDir)
        
        let deltaAngle = t * self.sweepAngle    // Implies that 0 < t < 1
        
        let spot = pointAtAngle(theta: startAngle + deltaAngle)   // Should have the start angle added!
        
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
    /// - Parameters:
    ///   - center: Point3D used for pivoting
    ///   - end1: Point3D on the perimeter
    ///   - end2: Point3D on the perimeter
    open static func isArcable(center: Point3D, end1: Point3D, end2: Point3D) -> Bool  {
        
        if !Point3D.isThreeUnique(alpha: center, beta: end1, gamma: end2)  { return false }
        
        let dist1 = Point3D.dist(pt1: center, pt2: end1)
        let dist2 = Point3D.dist(pt1: center, pt2: end2)
        
        let thumbsUp = abs(dist1 - dist2) < Point3D.Epsilon
        
        var vecStart = Vector3D.built(from: center, towards: end1)
        try! vecStart.normalize()
        
        var vecFinish = Vector3D.built(from: center, towards: end2)
        try! vecFinish.normalize()
        
        let flag1 = Vector3D.isOpposite(lhs: vecStart, rhs: vecFinish)
        
        return thumbsUp && !flag1
    }
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks
    /// Not implemented
    open func resolveNeighbor(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
        // TODO: Make this return something besides dummy values
//        let otherSpeck = speck
        let alongVector = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let perpVector = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        return (alongVector, perpVector)
    }
    
    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    /// As opposed to calling the function of CGContext?
    public func drawOld(context: CGContext, tform: CGAffineTransform)  {
        
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
    
    
    /// Plot the arc segment.  This will be called by the UIView 'drawRect' function
    /// - Warning:  This only works in the XY plane
    /// Notice that a model-to-display transform is applied
    public func draw(context: CGContext, tform: CGAffineTransform)  {
        
        let centerCG = CGPoint(x: self.ctr.x, y: self.ctr.y)   // Throw out Z information
        let displayCenter = centerCG.applying(tform)
        let radCG = CGFloat(self.rad) * tform.a   // This value should be the scale
        
        // Figure the start angle
        let startDir = Vector3D.built(from: self.ctr, towards: self.start)
        let thetaS = CGFloat(atan2(-1.0 * startDir.j, startDir.i))   // Because Y is positive downward on the screen
        
        // Figure the end angle
        let finishDir = Vector3D.built(from: self.ctr, towards: self.finish)
        let thetaF =  CGFloat(atan2(-1.0 * finishDir.j, finishDir.i))
        
        
        let startCG = CGPoint(x: self.start.x, y: self.start.y)   // Throw out Z information
        let displayStart = startCG.applying(tform)
        
        context.move(to: displayStart)
        context.addArc(center: displayCenter, radius: radCG, startAngle: thetaS, endAngle: thetaF, clockwise: self.sweepAngle > 0.0)
        
        context.strokePath()
        
    }
    
    /// Define the smallest aligned rectangle that encloses the arc
    /// Probably returns bad values half of the time in the current state
    func figureExtent() -> OrthoVol  {
        
        let rad = Point3D.dist(pt1: self.ctr, pt2: self.start)
        
        var mostY = ctr.y + rad
        var mostX = ctr.x + rad
        var leastY = ctr.y - rad
        var leastX = ctr.x - rad
        
        if !self.isFull   {
            
            var chord = Vector3D.built(from: start, towards: finish)
            try! chord.normalize()   // Checks in the constructor should keep this from being a zero vector
        
            let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)   // TODO: Make this not so brittle
            var split = try! Vector3D.crossProduct(lhs: up, rhs: chord)
            try! split.normalize()   // Checks in the crossProduct should keep this from being a zero vector
        
            let discard = split
//            if self.isClockwise   { discard = split.reverse()  }
        
        
            let north = Point3D(x: ctr.x, y: mostY, z: 0.0)
            let east = Point3D(x: mostX, y: ctr.y, z: 0.0)
            let south = Point3D(x: ctr.x, y: leastY, z: 0.0)
            let west = Point3D(x: leastX, y: ctr.y, z: 0.0)
        
                // Create vectors towards the compass points
            let goNorth = Vector3D.built(from: start, towards: north)    // These could very well be zero length
            let goEast = Vector3D.built(from: start, towards: east)
            let goSouth = Vector3D.built(from: start, towards: south)
            let goWest = Vector3D.built(from: start, towards: west)
        
        
            let northDot = Vector3D.dotProduct(lhs: discard, rhs: goNorth)
            let eastDot = Vector3D.dotProduct(lhs: discard, rhs: goEast)
            let southDot = Vector3D.dotProduct(lhs: discard, rhs: goSouth)
            let westDot = Vector3D.dotProduct(lhs: discard, rhs: goWest)
        
            if northDot > 0.0   { mostY = max(start.y, finish.y) }
            if eastDot > 0.0   { mostX = max(start.x, finish.x) }
            if southDot > 0.0   { leastY = min(start.y, finish.y) }
            if westDot > 0.0   { leastX = min(start.x, finish.x) }
        }
        
        return OrthoVol(minX: leastX, maxX: mostX, minY: leastY, maxY: mostY, minZ: -1 * rad / 10.0, maxZ: rad / 10.0)
    }
    
    
    
    /// Determine the range of angles covered by the arc
    /// Separated out for testing
    func findRange(useSmallAngle:  Bool) -> Double   {
    
        var vecStart = Vector3D.built(from: self.ctr, towards: self.start)
        try! vecStart.normalize()
        var vecFinish = Vector3D.built(from: self.ctr, towards: self.finish)
        try! vecFinish.normalize()
        
        /// Larger of the possible ranges
        var ccwSweep: Double
        
        let thetaStart = atan2(vecStart.j, vecStart.i)   // Between -M_PI and M_PI
        var thetaFinish = atan2(vecFinish.j, vecFinish.i)
        
        if thetaFinish >= 0.0   {
            ccwSweep = thetaFinish - thetaStart
            if ccwSweep < 0.0   { ccwSweep += 2.0 * M_PI }
        }  else  {
            thetaFinish += 2.0 * M_PI
            ccwSweep = thetaFinish - thetaStart
        }
        
        if useSmallAngle && ccwSweep > M_PI   {
            ccwSweep = -1.0 * (2.0 * M_PI - ccwSweep)   //2.0 * M_PI - ccwSweep
        }
        
        if !useSmallAngle && ccwSweep < M_PI   {
            ccwSweep = -1.0 * (2.0 * M_PI - ccwSweep)
        }
        
        return ccwSweep
    }
    
    
    /// Build the center of a circle from three points on the perimeter
    /// - Throws: ArcPointsError if there any coincident points in the inputs
    open static func findCenter(_ larry: Point3D, curly: Point3D, moe: Point3D) throws -> Point3D   {
        
        guard(Point3D.isThreeUnique(alpha: larry, beta: curly, gamma: moe))  else  { throw ArcPointsError(badPtA: larry, badPtB: curly, badPtC: moe)}
        
        
        /// The desired result to be returned
        var ctr = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        var vecA = Vector3D.built(from: larry, towards: curly)
        try! vecA.normalize()   // The guard statement above should keep this from being a zero vector
        
        var vecB = Vector3D.built(from: curly, towards: moe)
        try! vecB.normalize()   // The guard statement above should keep this from being a zero vector
        
        var axle = try! Vector3D.crossProduct(lhs: vecA, rhs: vecB)   // The guard statement above should keep these from being zero vectors
        try! axle.normalize()   // The crossProduct function should keep this from being a zero vector
        
        let midA = Point3D.midway(alpha: larry, beta: curly)
        var perpA = try! Vector3D.crossProduct(lhs: vecA, rhs: axle)
        try! perpA.normalize()   // The crossProduct function should keep this from being a zero vector
        
        let midB = Point3D.midway(alpha: curly, beta: moe)
        var perpB = try! Vector3D.crossProduct(lhs: vecB, rhs: axle)
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
        let axisFlag2 = Vector3D.isOpposite(lhs: lhs.getAxisDir(), rhs: rhs.getAxisDir())
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

