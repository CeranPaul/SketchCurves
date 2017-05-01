//
//  Arc.swift
//  SketchCurves
//
//  Created by Paul on 11/7/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

/// A circular arc - either whole, or a portion
/// The code compiles, but beware of the results!
/// This DOES NOT handle the case of precisely half a circle
/// - SeeAlso:  Ellipse
open class Arc: PenCurve {
    
    /// Point around which the arc is swept
    fileprivate var ctr: Point3D
    
    /// Pivot line
    fileprivate var axisDir: Vector3D
    
    /// Beginning point
    fileprivate var start: Point3D
    fileprivate var finish: Point3D
    
    /// Can be either positive or negative
    /// Magnitude should be less than 2 pi
    fileprivate var sweepAngle: Double
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    open var parameterRange: ClosedRange<Double>
    

    
    /// Derived radius of the Arc
    fileprivate var rad: Double
    
    /// Whether or not this is a complete circle
    open var isFull: Bool
    
    
    
    /// The simplest initializer
    /// - Parameters:
    ///   - center: Point3D used for pivoting
    ///   - axis: Unit vector, often in the +Z direction
    ///   - end1: Starting point
    ///   - sweep: Angle (in radians) in the CCW direction.  Can be positive or negative
    /// - Throws: ZeroVectorError, NonUnitDirectionError, CoincidentPointsError
    public init(center: Point3D, axis: Vector3D, end1: Point3D, sweep: Double) throws   {
        
        guard (!axis.isZero()) else  {throw ZeroVectorError(dir: axis)}
        guard (axis.isUnit()) else  {throw NonUnitDirectionError(dir: axis)}
        
        guard (center != end1)  else  { throw CoincidentPointsError(dupePt: end1) }

            // This is a misleading error type
        guard (sweep != 0.0)  else  { throw CoincidentPointsError(dupePt: end1) }
        
        let horiz = Vector3D.built(from: center, towards: end1, unit: true)
        
           // This is another misleading error type
        guard (Vector3D.dotProduct(lhs: axis, rhs: horiz) == 0.0)  else  { throw CoincidentPointsError(dupePt: end1) }
        
        
        self.ctr = center
        self.axisDir = axis
        self.start = end1
        self.sweepAngle = sweep
        
        self.rad = Point3D.dist(pt1: self.ctr, pt2: self.start)
        
            
        /// A vector perpendicular to horiz in the plane of the circle
        let vert = try! Vector3D.crossProduct(lhs: self.axisDir, rhs: horiz)
            
        let magnitudeH = self.rad * cos(sweepAngle)
        let deltaH = horiz * magnitudeH
            
        let magnitudeV = self.rad * sin(sweepAngle)
        let deltaV = vert * magnitudeV
            
        let jump = deltaH + deltaV
            
        self.finish = self.ctr.offset(jump: jump)
        
        
        self.usage = PenTypes.ordinary   // Use 'setIntent' to attach a different desired value
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        self.isFull = false
        if self.sweepAngle == 2.0 * Double.pi   { self.isFull = true }   // What about the negative equivalent?
        
    }
    
    
    /// Build an arc from a center and two terminating points - perhaps tangent points.
    /// Direction is derived from the ordering of end1 and end2
    /// - Warning: Will fail for a half or full circle
    /// - Parameters:
    ///   - center: Point3D used for pivoting
    ///   - end1: Point3D on the perimeter
    ///   - end2: Point3D on the perimeter
    ///   - useSmallAngle: ???
    /// - Throws: ArcPointsError
    public init(center: Point3D, end1: Point3D, end2: Point3D, useSmallAngle: Bool) throws   {
        
        guard (Arc.isArcable(center: center, end1: end1, end2: end2))  else  { throw ArcPointsError(badPtA: center, badPtB: end1, badPtC: end2) }
        
        self.ctr = center
        self.start = end1
        self.finish = end2
        
        let vecStart = Vector3D.built(from: center, towards: end1, unit: true)
        let vecFinish = Vector3D.built(from: center, towards: end2, unit: true)
        
        var spin = try! Vector3D.crossProduct(lhs: vecStart, rhs: vecFinish)
        spin.normalize()
        
        self.axisDir = spin
        
        
        self.rad = Point3D.dist(pt1: self.ctr, pt2: self.start)
        self.isFull = false
        self.usage = PenTypes.ordinary   // Use 'setIntent' to attach a different desired value
        
        
        let thetaStart = atan2(vecStart.j, vecStart.i)   // Between -M_PI and M_PI
        let thetaFinish = atan2(vecFinish.j, vecFinish.i)
        
        
        self.sweepAngle = abs(thetaFinish - thetaStart)   // Angle for the shorter path
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        if !useSmallAngle   {
            self.sweepAngle = self.sweepAngle - 2.0 * Double.pi
        }
        
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
    
    
    
    /// Find the point along this arc specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    /// - Returns: Point
    open func pointAt(t: Double) throws -> Point3D  {
        
           // Misuse of this error type
        guard (self.parameterRange.contains(t))  else  { throw CoincidentPointsError(dupePt: self.ctr) }
        
        let vecStart = Vector3D.built(from: self.ctr, towards: self.start, unit: true)
        
        let vert = try! Vector3D.crossProduct(lhs: self.axisDir, rhs: vecStart)   // Shouldn't need to be normalized
        
        let deltaAngle = t * self.sweepAngle    // Implies that 0 < t < 1
        
        let magnitudeH = self.rad * cos(deltaAngle)
        let deltaH = vecStart * magnitudeH
        
        let magnitudeV = self.rad * sin(deltaAngle)
        let deltaV = vert * magnitudeV
        
        let jump = deltaH + deltaV
        
        let spot = self.ctr.offset(jump: jump)
        
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
        
        let vecStart = Vector3D.built(from: center, towards: end1, unit: true)
        let vecFinish = Vector3D.built(from: center, towards: end2, unit: true)
        
        let flag1 = Vector3D.isOpposite(lhs: vecStart, rhs: vecFinish)
        
        return thumbsUp && !flag1
    }
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks
    /// Not implemented
    open func resolveRelative(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
        // TODO: Make this return something besides dummy values
//        let otherSpeck = speck
        let alongVector = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let perpVector = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        return (alongVector, perpVector)
    }
    
    /// Move, rotate, and scale by a matrix
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    open func transform(xirtam: Transform) throws -> PenCurve {
        
        let tAlpha = self.start.transform(xirtam: xirtam)
        let tCent = self.ctr.transform(xirtam: xirtam)
        let tAxis = self.axisDir.transform(xirtam: xirtam)
        
        let transformed = try Arc(center: tCent, axis: tAxis, end1: tAlpha, sweep: self.sweepAngle)   // Will generate a new extent
        
        transformed.setIntent(purpose: self.usage)   // Copy setting instead of having the default
        return transformed
    }
    
    
    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    /// Useful for Arcs that are not in the XY plane
    public func drawOld(context: CGContext, tform: CGAffineTransform)  {
        
        var xCG: CGFloat = CGFloat(self.start.x)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.start.y)
        
        let startModel = CGPoint(x: xCG, y: yCG)
        let screenStart = startModel.applying(tform)
        
        context.move(to: screenStart)
        
        
        for g in 1...20   {
            
            let stepU = Double(g) * 0.05   // Gee, this is brittle!
            xCG = CGFloat(try! pointAt(t: stepU).x)
            yCG = CGFloat(try! pointAt(t: stepU).y)
            //            print(String(describing: xCG) + "  " + String(describing: yCG))
            let midPoint = CGPoint(x: xCG, y: yCG)
            let midScreen = midPoint.applying(tform)
            context.addLine(to: midScreen)
        }
        
        context.strokePath()
        
    }
    
    
    /// Define the smallest aligned rectangle that encloses the arc
    /// Probably returns bad values half of the time in the current state
    public func getExtent() -> OrthoVol  {
        
        let rad = Point3D.dist(pt1: self.ctr, pt2: self.start)
        
        var mostY = ctr.y + rad
        var mostX = ctr.x + rad
        var leastY = ctr.y - rad
        var leastX = ctr.x - rad
        
        if !self.isFull   {
            
            let chord = Vector3D.built(from: start, towards: finish, unit: true)
        
            let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)   // TODO: Make this not so brittle
            var split = try! Vector3D.crossProduct(lhs: up, rhs: chord)
            split.normalize()   // Checks in the crossProduct should keep this from being a zero vector
        
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
    
    
    
    /// Build the center of a circle from three points on the perimeter
    /// - Throws: ArcPointsError if there any coincident points in the inputs
    open static func findCenter(larry: Point3D, curly: Point3D, moe: Point3D) throws -> Point3D   {
        
        guard(Point3D.isThreeUnique(alpha: larry, beta: curly, gamma: moe))  else  { throw ArcPointsError(badPtA: larry, badPtB: curly, badPtC: moe)}
        
        
        /// The desired result to be returned
        var ctr = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        let vecA = Vector3D.built(from: larry, towards: curly, unit: true)
        let vecB = Vector3D.built(from: curly, towards: moe, unit: true)
        
        var axle = try! Vector3D.crossProduct(lhs: vecA, rhs: vecB)   // The guard statement above should keep these from being zero vectors
        axle.normalize()   // The crossProduct function should keep this from being a zero vector
        
        let midA = Point3D.midway(alpha: larry, beta: curly)
        var perpA = try! Vector3D.crossProduct(lhs: vecA, rhs: axle)
        perpA.normalize()   // The crossProduct function should keep this from being a zero vector
        
        let midB = Point3D.midway(alpha: curly, beta: moe)
        var perpB = try! Vector3D.crossProduct(lhs: vecB, rhs: axle)
        perpB.normalize()   // The crossProduct function should keep this from being a zero vector
        
        
        do   {
            
            let pLineA = try Line(spot: midA, arrow: perpA)
            let pLineB = try Line(spot: midB, arrow: perpB)
            
            ctr = try Line.intersectTwo(straightA: pLineA, straightB: pLineB)
            
        }  catch  {
            print("Finding the circle center didn't work out.")
        }
        
        return ctr
    }
    
    /// Check for two having the same center point and axis
    /// - Parameter: lhs: One Arc
    /// - Parameter: rhs: Another Arc
    /// - SeeAlso:  Overloaded ==
    open static func isConcentric(lhs: Arc, rhs: Arc) -> Bool  {
        
        let ctrFlag = lhs.ctr == rhs.ctr
        
        let axisFlag1 = lhs.getAxisDir() == rhs.getAxisDir()
        let axisFlag2 = Vector3D.isOpposite(lhs: lhs.getAxisDir(), rhs: rhs.getAxisDir())
        let axisFlag = axisFlag1 || axisFlag2
        
        return ctrFlag && axisFlag
    }
    
    /// Plot the arc segment.  This will be called by the UIView 'drawRect' function
    /// - Warning:  This only works in the XY plane
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
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

