//
//  Line.swift
//  SketchCurves
//
//  Created by Paul on 8/12/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Unbounded and straight
public struct Line: Equatable {
    
    /// A point to locate the line
    fileprivate var origin: Point3D
    
    /// Which way it extends
    fileprivate var direction: Vector3D
    
    
    /// Build a fresh one - with error checking
    /// - Parameters:
    ///   - spot:  Origin for the fresh line
    ///   - arrow:  Direction for the fresh line.  Must have unit length
    /// - Throws: 
    ///   - ZeroVectorError if the input Vector3D has no length
    ///   - NonUnitDirectionError for a bad input Vector3D
    init (spot: Point3D, arrow: Vector3D) throws  {
        
        guard !arrow.isZero() else  {throw ZeroVectorError(dir: arrow)}
        guard arrow.isUnit() else  {throw NonUnitDirectionError(dir: arrow)}
        
        self.origin = spot
        self.direction = arrow
    }
    
    /// Simple getter for the origin
    public func getOrigin() -> Point3D  {
        
        return self.origin
    }
    
    /// Simple getter for the direction
    public func getDirection() -> Vector3D  {
        
        return self.direction
    }
    
    
    
    /// Find the position of a point relative to the line and its origin
    /// The returned perp distance will always be positive
    /// - Parameters:
    ///   - yonder:  Trial point
    /// - Returns: Tuple of distances
    /// - SeeAlso:  'resolveRelative(Vector)'
    public func resolveRelative(yonder: Point3D) -> (along: Double, perp: Double)   {
        
        let bridge = Vector3D.built(from: self.origin, towards: yonder)
        let along = Vector3D.dotProduct(lhs: bridge, rhs: self.direction)
        
        let alongVector = self.direction * along
        let perpVector = bridge - alongVector
        let perp = perpVector.length()
        
        return (along, perp)
    }
    

    /// Find the components of a vector relative to the line
    /// - Parameters:
    ///   - arrow:  Trial Vector
    /// - Returns: Tuple of Vectors
    /// - SeeAlso:  'resolveRelative(Point)'
    public func resolveRelative(arrow: Vector3D) -> (along: Vector3D, perp: Vector3D)   {
        
        let along = Vector3D.dotProduct(lhs: arrow, rhs: self.direction)
        let alongVector = self.direction * along
        
        let perpVector = arrow - alongVector
        
        return (alongVector, perpVector)
    }
    
    
    /// Project a point to the Line
    /// - Parameters:
    ///   - away:  Hanging point
    /// - Returns: Nearest point on line
    public func dropPoint(away: Point3D) -> Point3D   {
        
        if Line.isCoincident(straightA: self, trial: away)   {  return away  }   // Shortcut!
        
        let bridge = Vector3D.built(from: self.origin, towards: away)
        let along = Vector3D.dotProduct(lhs: bridge, rhs: self.direction)
        let alongVector = self.direction * along
        let onLine = self.origin.offset(jump: alongVector)
        
        return onLine
    }
    
    /// Checks to see if the trial point lies on the line
    /// - SeeAlso:  Overloaded ==
    public static func isCoincident(straightA: Line, trial: Point3D) -> Bool   {
        
        var bridgeVector = Vector3D.built(from: straightA.origin, towards: trial)
        
        if bridgeVector.isZero() { return true }
        
        bridgeVector.normalize()   // The zero length check above should keep this safe
        
        let same = bridgeVector == straightA.direction
        let opp = Vector3D.isOpposite(lhs: straightA.direction, rhs: bridgeVector)
        
        return same || opp
    }
    

    /// Check two lines  See that the either origin lies on the other line, and
    /// that they have the same direction, even with the opposite sense
    /// - SeeAlso:  Overloaded ==
    public static func isCoincident(straightA: Line, straightB: Line) -> Bool   {
        
        if !Line.isCoincident(straightA: straightA, trial: straightB.getOrigin())   { return false }
        if !Line.isCoincident(straightA: straightB, trial: straightA.getOrigin())   { return false }
        
        if !Line.isParallel(straightA: straightA, straightB: straightB)   { return false }
        
        return true
    }
    
    /// Do two lines have the same direction, even with opposite sense?
    /// - Parameters:
    ///   - straightA:  First test line
    ///   - straightB:  Second test line
    /// - SeeAlso:  Overloaded ==
    public static func isParallel(straightA: Line, straightB: Line) -> Bool   {
        
        let sameFlag = straightA.getDirection() == straightB.getDirection()
        let oppFlag = Vector3D.isOpposite(lhs: straightA.getDirection(), rhs: straightB.getDirection())
        
        return sameFlag  || oppFlag
    }
    
    
    /// Verify that lines are on the same plane
    /// - Parameters:
    ///   - straightA:  First test line
    ///   - straightB:  Second test line
    /// - SeeAlso:  Overloaded ==
    /// - SeeAlso:  Line.isParallel()
    public static func isCoplanar(straightA: Line, straightB: Line) -> Bool   {
        
        if Line.isCoincident(straightA: straightA, straightB: straightB) { return true }
        
        var bridgeVector = Vector3D.built(from: straightA.getOrigin(), towards: straightB.getOrigin())
        
        if bridgeVector.isZero() { return true }
        
        bridgeVector.normalize()   // The zero length check above should keep this safe
        
        var perp1 = try! Vector3D.crossProduct(lhs: straightA.getDirection(), rhs: bridgeVector)
        perp1.normalize()   // The checks in crossProduct should keep this from being a zero vector
        
        var perp2 = try! Vector3D.crossProduct(lhs: bridgeVector, rhs: straightA.getDirection())
        perp2.normalize()   // The checks in crossProduct should keep this from being a zero vector
        
        let sameFlag = perp1 == perp2
        let oppFlag = Vector3D.isOpposite(lhs: perp1, rhs: perp2)
        
        return sameFlag  || oppFlag
    }
    
    
    /// Generate a point by intersecting two Lines
    /// - Throws: CoincidentLinesError if the inputs are the same
    /// - Throws: ParallelLinesError if the inputs are parallel
    /// - Throws: NonCoPlanarLinesError if the inputs don't lie in the same plane
    public static func intersectTwo (straightA: Line, straightB: Line) throws -> Point3D  {
        
        guard !Line.isCoincident(straightA: straightA, straightB: straightB) else { throw CoincidentLinesError(enil: straightA)}
        
        guard !Line.isParallel(straightA: straightA, straightB: straightB)  else { throw ParallelLinesError(enil: straightA) }
        
        guard Line.isCoplanar(straightA: straightA, straightB: straightB)  else { throw NonCoPlanarLinesError(enilA: straightA, enilB: straightB) }
        
        if Line.isCoincident(straightA: straightA, trial: straightB.getOrigin())   { return straightB.getOrigin() }
        if Line.isCoincident(straightA: straightB, trial: straightA.getOrigin())   { return straightA.getOrigin() }
        if straightA.getOrigin() == straightB.getOrigin()   { return straightA.getOrigin() }
        
        
        let bridgeVector = Vector3D.built(from: straightA.getOrigin(), towards: straightB.getOrigin())
        
        /// Components (vectors) of the full-length bridge vector relative to Line straightA
        let comps = straightA.resolveRelative(arrow: bridgeVector)
        
        var perpDir = comps.perp
        perpDir.normalize()  // The coincidence checks above should keep the vector from having zero length
        
        let propor = Vector3D.dotProduct(lhs: perpDir, rhs: straightB.getDirection())
        let perpLen = comps.perp.length()
        
        /// Length along B to the intersection
        let lengthB =  -1.0 * perpLen / propor;
        
        let alongB = straightB.getDirection() * lengthB;
        
        return straightB.getOrigin().offset(jump: alongB);
    }
    
    
}    // End of definition for struct Line



/// Check to see that the second origin lies on the first Line, and that
///  the directions are identical  Opposite direction will fail this test
/// - SeeAlso:  isCoincident
public func == (lhs: Line, rhs: Line) -> Bool   {
    
    let flag1 = Line.isCoincident(straightA: lhs, trial: rhs.origin)
    
    let flag2 = lhs.direction == rhs.direction
    
    return flag1 && flag2    
}

