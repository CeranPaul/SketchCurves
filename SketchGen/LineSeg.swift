//
//  LineSeg.swift
//  SketchCurves
//
//  Created by Paul on 10/28/15.
//  Copyright © 2018 Ceran Digital Media. See LICENSE.md
//

import UIKit

/// A wire between two points
public class LineSeg: PenCurve {    // Can this be a struct, instead?
    
    // End points
    fileprivate var endAlpha: Point3D   // Private access to limit modification
    fileprivate var endOmega: Point3D
        
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes

    open var parameterRange: ClosedRange<Double>
    
    
    /// Build a line segment from two points
    /// - Throws: CoincidentPointsError
    /// - Parameters:
    ///   - end1: One terminating point
    ///   - end2:  The other terminating point
    /// - Throws: CoincidentPointsError if the two ends are identical
    /// - See: 'testFidelity' under LineSegTests
    public init(end1: Point3D, end2: Point3D) throws {
        
        guard end1 != end2 else { throw CoincidentPointsError(dupePt: end1)}
        
        self.endAlpha = end1
        self.endOmega = end2
        
        self.usage = PenTypes.ordinary
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Fetch the location of an end
    /// - See: 'getOtherEnd()'
    /// - See: 'testFidelity' under LineSegTests
    open func getOneEnd() -> Point3D   {
        return endAlpha
    }
    
    
    /// Fetch the location of the opposite end
    /// - See: 'getOneEnd()'
    /// - See: 'testFidelity' under LineSegTests
    open func getOtherEnd() -> Point3D   {
        return endOmega
    }
    

    
    /// Modify either of the end points
    /// - Parameters:
    ///   - newLoc:  New location
    ///   - head: Modify the head point, or the tail point?
    /// - Throws: CoincidentPointsError if the new point would result in zero length
    public func changeEnd(newLoc: Point3D, head: Bool) throws -> Void  {
                
        if head   {
            guard (newLoc != endOmega) else  { throw CoincidentPointsError(dupePt: newLoc) }
        }  else   {
            guard (newLoc != endAlpha) else  { throw CoincidentPointsError(dupePt: newLoc) }
        }
        
        
        if head   {
            endAlpha = newLoc
        }  else  {
            endOmega = newLoc
        }
        
    }
    

    /// Attach new meaning to the curve
    /// - See: 'testSetIntent' under LineSegTests
    open func setIntent(purpose: PenTypes)   {
        
        self.usage = purpose
    }
    
    
    /// Calculate length
    /// - See: 'testLength' under LineSegTests
    func getLength() -> Double   {
        
        return Point3D.dist(pt1: self.endAlpha, pt2: self.endOmega)
    }
    

    /// Find the point along this line segment specified by the parameter 't'
    /// Assumes 0 < t < 1
    /// - See: 'testPointAt' under LineSegTests
    open func pointAt(t: Double) throws -> Point3D  {
        
        let wholeVector = Vector3D.built(from: self.endAlpha, towards: self.endOmega, unit: false)
        
        let scaled = wholeVector * t
        
        let spot = self.endAlpha.offset(jump: scaled)
        
        return spot
    }
    
    
    /// Return the tangent vector, which won't depend on the input parameter
    /// Some notations show "u" as the parameter, instead of "t"
    /// - Returns:
    ///   - tan:  Normalized vector
    public func tangentAt(t: Double) -> Vector3D   {
        
        return self.getDirection()
    }
    

    /// Get the box that bounds the curve
    /// - Returns: A brick aligned to the CSYS axes.
    public func getExtent() -> OrthoVol  {
        
        return try! OrthoVol(corner1: self.endAlpha, corner2: self.endOmega)   // If the points were coincident,
                                                                               // the instance could not have been built.
    }
    
    /// Create a unit vector showing direction.
    /// - Returns: Unit vector to indicate direction
    open func getDirection() -> Vector3D   {
        
        return Vector3D.built(from: self.endAlpha, towards: self.endOmega, unit: true)
    }
    
    /// Flip the order of the end points  Used to align members of a Perimeter
    /// - See: 'testReverse' under LineSegTests
    open func reverse() -> Void  {
        
        let bubble = self.endAlpha
        self.endAlpha = self.endOmega
        self.endOmega = bubble
    }
    
    
    /// Move, rotate, and scale by a matrix.
    /// A member function, because polymorphism is useful across PenCurves.
    /// - Parameters:
    ///   - xirtam:  Move, scale, or rotate to be performed
    /// - Throws: CoincidentPointsError if it was scaled to be very small
    public func transform(xirtam: Transform) throws -> PenCurve {
        
        let tAlpha = Point3D.transform(pip: endAlpha, xirtam: xirtam)
        let tOmega = Point3D.transform(pip: endOmega, xirtam: xirtam)
        
        let transformed = try LineSeg(end1: tAlpha, end2: tOmega)   // Will generate a new extent
        transformed.setIntent(purpose: self.usage)   // Copy setting instead of having the default
        
        return transformed
    }
    
    /// Find two vectors describing the position of a point relative to the LineSeg.
    /// - Parameters:
    ///   - speck:  Point of interest
    /// - Returns: Tuple of vectors - one along the seg, other perp to it
    /// - See: 'testResolveRelative' under LineSegTests
    public func resolveRelative(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
        /// Direction of the segment.  Is a unit vector.
        let thisWay = self.getDirection()
        
        let bridge = Vector3D.built(from: self.endAlpha, towards: speck)
        
        let along = Vector3D.dotProduct(lhs: bridge, rhs: thisWay)
        let alongVector = thisWay * along
        let perpVector = bridge - alongVector
        
        return (alongVector, perpVector)
    }
    
    
    /// See if another segment crosses this one
    /// Used for seeing if a screen gesture cuts across the current seg
    /// - Parameters:
    ///   - chop:  Candidate LineSeg
    /// - Returns: A simple flag
    /// - See: 'testIsCrossing' under LineSegTests
    public func isCrossing(chop: LineSeg) -> Bool   {
        
        let compsA = self.resolveRelative(speck: chop.endAlpha)
        let compsB = self.resolveRelative(speck: chop.endOmega)
        
        // Should be negative if ends are on opposite sides
        let compliance = Vector3D.dotProduct(lhs: compsA.perp, rhs: compsB.perp)
        
        let flag1 = compliance < 0.0
        
        let farthest = self.getLength()
        
        let flag2A = compsA.along.length() <= farthest
        let flag2B = compsB.along.length() <= farthest
        
        return flag1 && flag2A && flag2B
    }
    
    
    // TODO:  Add a function to generate n equally spaced points between end points
    
    
    /// Build a parallel line towards the inside.
    /// Should this become a static func?
    /// - Parameters:
    ///   - inset:  Distance desired for the offset
    ///   - stbdIn:  Whether starboard represents "in"
    ///   - upward:  Unit vector perpendicular to the plane of the Perimeter
    /// - Returns: A Line, not a LineSeg
    /// - See: 'testInsetLine' under LineSegTests
    public func insetLine(inset: Double, stbdIn: Bool, upward: Vector3D) -> Line   {
        
        let thataway = self.getDirection()
        
        /// Across the segment
        var trans = try! Vector3D.crossProduct(lhs: thataway, rhs: upward)
        trans.normalize()
        
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
    /// - See: 'testClipTo' under LineSegTests
    public func clipTo(stub: Point3D, keepNear: Bool) -> LineSeg   {
        
        var freshSeg: LineSeg
        
        if keepNear   {
            freshSeg = try! LineSeg(end1: self.getOneEnd(), end2: stub)
        }  else  {
            freshSeg = try! LineSeg(end1: stub, end2: self.getOtherEnd())
        }
        
        return freshSeg
    }
    
    
    /// Plot the line segment.  This will be called by the UIView 'drawRect' function.
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    public func draw(context: CGContext, tform: CGAffineTransform) -> Void  {
        
        context.beginPath()
        
        var spot = CGPoint(x: self.endAlpha.x, y: self.endAlpha.y)    // Throw out Z coordinate
        var screenSpot = spot.applying(tform)
        context.move(to: screenSpot)
        
        spot = CGPoint(x: self.endOmega.x, y: self.endOmega.y)    // Throw out Z coordinate
        screenSpot = spot.applying(tform)
        context.addLine(to: screenSpot)
        
        context.strokePath()
    }

    
    /// Draw symbols to be used in manipulating the curve.
    /// Still needs a handle for dragging
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    public func drawControls(context: CGContext, tform: CGAffineTransform) -> Void  {
        
        let boxDim = 8.0
        let boxSize = CGSize(width: boxDim, height: boxDim)
        
        var xCG = CGFloat(endAlpha.x)
        var yCG = CGFloat(endAlpha.y)
        var boxCenter = CGPoint(x: xCG, y: yCG).applying(tform)
        var boxOrigin = CGPoint(x: boxCenter.x - CGFloat(boxDim / 2.0), y: boxCenter.y - CGFloat(boxDim / 2.0))
        var controlBox = CGRect(origin: boxOrigin, size: boxSize)
        context.fill(controlBox)
        
        xCG = CGFloat(endOmega.x)
        yCG = CGFloat(endOmega.y)
        boxCenter = CGPoint(x: xCG, y: yCG).applying(tform)
        boxOrigin = CGPoint(x: boxCenter.x - CGFloat(boxDim / 2.0), y: boxCenter.y - CGFloat(boxDim / 2.0))
        controlBox = CGRect(origin: boxOrigin, size: boxSize)
        context.fill(controlBox)
        
    }
        
    /// Create a String that is suitable JavaScript to draw the LineSeg.
    /// Assumes that the context has a plot location of the starting point for the LineSeg.
    /// - Parameters:
    ///   - xirtam:  Model-to-display transform
    /// - Returns: String consisting of JavaScript to plot
    public func jsDraw(xirtam: Transform) -> String {
        
        /// The output line
        var singleLine: String
        
        let plotEnd = Point3D.transform(pip: self.getOtherEnd(), xirtam: xirtam)
        
        let endX = Int(plotEnd.x + 0.5)   // The default is to round towards zero
        let endY = Int(plotEnd.y + 0.5)
        
        singleLine = "ctx.lineTo(" + String(endX) + ", " + String(endY) + ");\n"
        
        return singleLine
    }
    
    /// Find possible intersection points with a line.
    /// - Parameters:
    ///   - ray:  The Line to be used for intersecting
    ///   - accuracy:  Optional - How close is close enough?
    /// - Returns: Array of points common to both curves.  Empty if parallel or outside extent, count of one for an intersection, and two if coincident.
    /// - See: 'testIntersectLine' under LineSegTests
    public func intersect(ray: Line, accuracy: Double = Point3D.Epsilon) -> [Point3D] {
        
        /// The return array
        var crossings = [Point3D]()
        
        /// Line built from this segment
        let unbounded = try! Line(spot: self.getOneEnd(), arrow: self.getDirection())   // Vector will be legitimate
        
        
        if Line.isParallel(straightA: unbounded, straightB: ray)   {   // Deal with parallel lines
            
            if Line.isCoincident(straightA: unbounded, straightB: ray)   {   // Coincident lines
                
                crossings.append(self.getOneEnd())
                crossings.append(self.getOtherEnd())
                
            }
            
        }  else  {   // Not parallel lines
            
            /// Intersection of the two lines
            let collision = try! Line.intersectTwo(straightA: unbounded, straightB: ray)
            
            /// Vector from segment origin towards intersection
            let rescue = Vector3D.built(from: self.getOneEnd(), towards: collision, unit: true)
            
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
    
    
    /// Calculate the crown over a small segment
    /// - Parameters:
    ///   - smallerT:  Ignored parameter value
    ///   - largerT:  Ignored parameter value
    /// - See: 'testCrown' under LineSegTests
    public func findCrown(smallerT: Double, largerT: Double) -> Double   {
        
        return 0.0
        
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
    
}
