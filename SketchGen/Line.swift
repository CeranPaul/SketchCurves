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
    
    
    // Force the direction vector to have unit length
    /// - Throws: ZeroVectorError if the input Vector3D has no length
    init (spot: Point3D, arrow: Vector3D) throws  {
        
        self.origin = spot
        self.direction = arrow

        // Because this is an 'init', this cannot be done at the top
        guard (!self.direction.isZero()) else  {throw ZeroVectorError(dir: self.direction)}
        guard (self.direction.isUnit()) else  {throw NonUnitDirectionError(dir: self.direction)}
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
    public func resolveRelative(_ yonder: Point3D) -> (along: Double, perp: Double)   {
        
        let bridge = Vector3D.built(from: self.origin, towards: yonder)
        let along = Vector3D.dotProduct(lhs: bridge, rhs: self.direction)
        let alongVector = self.direction * along
        let perpVector = bridge - alongVector
        let perp = perpVector.length()
        
        return (along, perp)
    }
    

    /// Find the components of a vector relative to the line
    public func resolveRelative(_ arrow: Vector3D) -> (along: Vector3D, perp: Vector3D)   {
        
        let along = Vector3D.dotProduct(lhs: arrow, rhs: self.direction)
        
        let alongVector = self.direction * along
        
        let perpVector = arrow - alongVector
        
        return (alongVector, perpVector)
    }
    
    
    /// Project a point to the Line
    public func dropPoint(_ away: Point3D) -> Point3D   {
        
        if Line.isCoincident(self, trial: away)   {  return away  }   // Shortcut!
        
        let bridge = Vector3D.built(from: self.origin, towards: away)
        let along = Vector3D.dotProduct(lhs: bridge, rhs: self.direction)
        let alongVector = self.direction * along
        let onLine = self.origin.offset(jump: alongVector)
        
        return onLine
    }
    
    /// Checks to see if the trial point lies on the line
    /// - SeeAlso:  Overloaded ==
    public static func isCoincident(_ straightA: Line, trial: Point3D) -> Bool   {
        
        var bridgeVector = Vector3D.built(from: straightA.origin, towards: trial)
        
        if bridgeVector.isZero() { return true }
        
        try! bridgeVector.normalize()   // The zero length check above should keep this safe
        
        let same = bridgeVector == straightA.direction
        let opp = Vector3D.isOpposite(lhs: straightA.direction, rhs: bridgeVector)
        
        return same || opp
    }
    

    /// Do two lines have the same direction, even with opposite sense?
    /// - SeeAlso:  Overloaded ==
    public static func isParallel(_ straightA: Line, straightB: Line) -> Bool   {
        
        let sameFlag = straightA.getDirection() == straightB.getDirection()
        let oppFlag = Vector3D.isOpposite(lhs: straightA.getDirection(), rhs: straightB.getDirection())
        
        return sameFlag  || oppFlag
    }
    
    
    /// Check two lines  See that the either origin lies on the other line, and
    /// that they have the same direction, even with the opposite sense
    /// - SeeAlso:  Overloaded ==
    public static func isCoincident(_ straightA: Line, straightB: Line) -> Bool   {
        
        if !Line.isCoincident(straightA, trial: straightB.getOrigin())   { return false }
        if !Line.isCoincident(straightB, trial: straightA.getOrigin())   { return false }
        
        if !Line.isParallel(straightA, straightB: straightB)   { return false }
        
        return true
    }
    
    /// Verify that lines are on the same plane
    /// isCoincident should be run first
    /// - SeeAlso:  Overloaded ==
    /// - SeeAlso:  Line.isParallel()
    public static func isCoPlanar(_ straightA: Line, straightB: Line) -> Bool   {
        
        var bridgeVector = Vector3D.built(from: straightA.getOrigin(), towards: straightB.getOrigin())
        
        if bridgeVector.isZero() { return true }
        
        try! bridgeVector.normalize()   // The zero length check above should keep this safe
        
        var perp1 = try! Vector3D.crossProduct(lhs: straightA.getDirection(), rhs: bridgeVector)
        try! perp1.normalize()   // The checks in crossProduct should keep this from being a zero vector
        
        var perp2 = try! Vector3D.crossProduct(lhs: bridgeVector, rhs: straightA.getDirection())
        try! perp2.normalize()   // The checks in crossProduct should keep this from being a zero vector
        
        let sameFlag = perp1 == perp2
        let oppFlag = Vector3D.isOpposite(lhs: perp1, rhs: perp2)
        
        return sameFlag  || oppFlag
    }
    
    
    /// Generate a point by intersecting two Lines
    /// - Throws: CoincidentLinesError if the inputs are the same
    /// - Throws: ParallelLinesError if the inputs are parallel
    /// - Throws: NonCoPlanarLinesError if the inputs don't lie in the same plane
    public static func intersectTwo (_ straightA: Line, straightB: Line) throws -> Point3D  {
        
        guard !Line.isCoincident(straightA, straightB: straightB) else { throw CoincidentLinesError(enil: straightA)}
        
        guard !Line.isParallel(straightA, straightB: straightB)  else { throw ParallelLinesError(enil: straightA)}
        
        guard Line.isCoPlanar(straightA, straightB: straightB)  else { throw NonCoPlanarLinesError(enilA: straightA, enilB: straightB)}
        
        if Line.isCoincident(straightA, trial: straightB.getOrigin())   { return straightB.getOrigin() }
        if Line.isCoincident(straightB, trial: straightA.getOrigin())   { return straightA.getOrigin() }
        if straightA.getOrigin() == straightB.getOrigin()   { return straightA.getOrigin() }
        
        
        let bridgeVector = Vector3D.built(from: straightA.getOrigin(), towards: straightB.getOrigin())
        
        /// Components (vectors) of the full-length bridge vector relative to Line straightA
        let comps = straightA.resolveRelative(bridgeVector)
        
        var perpDir = comps.perp
        try! perpDir.normalize()  // The coincidence checks above should keep the vector from having zero length
        
        let propor = Vector3D.dotProduct(lhs: perpDir, rhs: straightB.getDirection())
        let perpLen = comps.perp.length()
        
        /// Length along B to the intersection
        let lengthB =  -1.0 * perpLen / propor;
        
        let alongB = straightB.getDirection() * lengthB;
        
        return straightB.getOrigin().offset(jump: alongB);
    }
    
    
    /// Construct a line by intersecting two planes
    /// - Throws: ParallelPlanesError if the inputs are parallel
    /// - Throws: CoincidentPlanesError if the inputs are coincident
    public static func intersectPlanes(_ flatA: Plane, flatB: Plane) throws -> Line   {
        
        guard !Plane.isParallel(flatA, rhs: flatB) else { throw ParallelPlanesError(enalpA: flatA)}
            
        guard !Plane.isCoincident(flatA, rhs: flatB) else { throw CoincidentPlanesError(enalpA: flatA)}
        
        
        /// Direction of the intersection line
        var lineDir = try! Vector3D.crossProduct(lhs: flatA.getNormal(), rhs: flatB.getNormal())
        try! lineDir.normalize()   // Checks in crossProduct should keep this from being a zero vector
        
        /// Vector on plane B that is perpendicular to the intersection line
        var perpInB = try! Vector3D.crossProduct(lhs: lineDir, rhs: flatB.getNormal())
        try! perpInB.normalize()   // Checks in crossProduct should keep this from being a zero vector
        
          // The ParallelPlanesError or CoincidentPlanesError should be avoided by the guard statements
            
        let lineFromCenterB =  try Line(spot: flatB.getLocation(), arrow: perpInB)  // Can be either towards flatA,
                                                                                   // or away from it
            
        let intersectionPoint = try Point3D.intersectLinePlane(enil: lineFromCenterB, enalp: flatA)
        let common = try Line(spot: intersectionPoint, arrow: lineDir)
        
        return common
    }
    
}    // End of definition for struct Line



/// Check to see that the second origin lies on the first Line, and that
///  the directions are identical  Opposite direction will fail this test
/// - SeeAlso:  isCoincident
public func == (lhs: Line, rhs: Line) -> Bool   {
    
    let flag1 = Line.isCoincident(lhs, trial: rhs.origin)
    
    let flag2 = lhs.direction == rhs.direction
    
    return flag1 && flag2    
}

