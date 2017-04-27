//
//  Plane.swift
//  SketchCurves
//
//  Created by Paul on 8/11/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Unbounded flat surface
public struct Plane   {
    
    /// A point to locate the plane
    internal var location: Point3D
    
    /// A vector perpendicular to the plane
    internal var normal: Vector3D
    
    
    /// Records parameters and checks to see that the normal is a legitimate vector
    /// - See: 'testFidelity' under PlaneTests
    init(spot: Point3D, arrow: Vector3D) throws  {
        
        guard (!arrow.isZero())  else  {throw ZeroVectorError(dir: arrow)}
        guard (arrow.isUnit())  else  {throw NonUnitDirectionError(dir: arrow)}
        
        self.location = spot
        self.normal = arrow
        
        // TODO:  Include tests to verify that the errors get thrown correctly

    }
    
    /// Generate a perpendicular vector from differences between the inputs
    /// Normal could be the opposite of what you hoped for
    /// - Parameters:
    ///   - alpha:  First input point and origin of the fresh plane
    ///   - beta:  Second input point
    ///   - gamma:  Third input point
    /// - Returns: Fresh plane
    /// - Throws: CoincidentPointsError for duplicate or linear inputs
    init(alpha: Point3D, beta: Point3D, gamma: Point3D) throws   {
        
        guard (Point3D.isThreeUnique(alpha: alpha, beta: beta, gamma: gamma)) else { throw CoincidentPointsError(dupePt: alpha) }
        
        // TODO: Come up with a better error type
        guard (!Point3D.isThreeLinear(alpha: alpha, beta: beta, gamma: gamma))  else  { throw CoincidentPointsError(dupePt: alpha) }
        
        
        self.location = alpha
        
        let thisWay = Vector3D.built(from: alpha, towards: beta)
        let thatWay = Vector3D.built(from: alpha, towards: gamma)
        
        var perpTo = try! Vector3D.crossProduct(lhs: thisWay, rhs: thatWay)
        try! perpTo.normalize()
        
        self.normal = perpTo
    }
    
    /// A getter for the point defining the plane
    /// - See: 'testLocationGetter' under PlaneTests
    public func getLocation() -> Point3D   {
        
        return self.location
    }
    
    /// A getter for the vector defining the plane
    /// - See: 'testNormalGetter' under PlaneTests
    public func getNormal() -> Vector3D   {
        
        return self.normal
    }
    
    
    
    /// Check to see that the line direction is perpendicular to the normal
    public static func isParallel(flat: Plane, enil: Line) -> Bool   {
        
        let perp = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: flat.normal)
        
        return abs(perp) < Vector3D.EpsilonV
    }
    
    /// Check to see that the line is parallel to the plane, and lies on it
    public static func isCoincident(enalp: Plane, enil: Line) -> Bool  {
        
        return self.isParallel(flat: enalp, enil: enil) && Plane.isCoincident(flat: enalp, pip: enil.getOrigin())
    }
    
    
    /// Does the argument point lie on the plane?
    /// - See: 'testIsCoincident' under PlaneTests
    public static func isCoincident(flat: Plane, pip:  Point3D) -> Bool  {
        
        if pip == flat.getLocation()   {  return true  }   // Shortcut!
        
        let bridge = Vector3D.built(from: flat.location, towards: pip)
        
        // This can be positive, negative, or zero
        let distanceOffPlane = Vector3D.dotProduct(lhs: bridge, rhs: flat.normal)
        
        return  abs(distanceOffPlane) < Point3D.Epsilon
    }
    
    /// Are the normals either parallel or opposite?
    /// - SeeAlso:  isCoincident and ==
    public static func isParallel(lhs: Plane, rhs: Plane) -> Bool{
        
        return lhs.normal == rhs.normal || Vector3D.isOpposite(lhs: lhs.normal, rhs: rhs.normal)
    }
    
    /// Planes are parallel, and rhs location lies on lhs
    /// - SeeAlso:  isParallel and ==
    public static func isCoincident(lhs: Plane, rhs: Plane) -> Bool  {
        
        return Plane.isCoincident(flat: lhs, pip: rhs.location) && Plane.isParallel(lhs: lhs, rhs: rhs)
    }
    
    
    /// Construct a parallel plane offset some distance
    /// - Parameters:
    ///   - base:  The reference plane
    ///   - offset:  Desired separation
    ///   - reverse:  Flip the normal, or not
    /// - Returns: Fresh plane, with separation
    /// - Throws:
    ///   - ZeroVectorError if base somehow got corrupted
    ///   - NonUnitDirectionError if base somehow got corrupted
    public static func buildParallel(base: Plane, offset: Double, reverse: Bool) throws -> Plane  {
    
        let jump = base.normal * offset    // offset can be a negative number
        
        let origPoint = base.location
        let newLoc = origPoint.offset(jump: jump)
        
        
        var newNorm = base.normal
        
        if reverse   {
            newNorm = base.normal * -1.0
        }
        
        let sparkle =  try Plane(spot: newLoc, arrow: newNorm)
    
        return sparkle
    }
    
    
    /// Construct a new plane perpendicular to an existing plane, and through a line on that plane
    /// Normal could be the opposite of what you hoped for
    /// - Parameters:
    ///   - enil:  Location for a fresh plane
    ///   - enalp:  The reference plane
    /// - Returns: Fresh plane
    /// - Throws:
    ///   - ZeroVectorError if enalp somehow got corrupted
    ///   - NonUnitDirectionError if enalp somehow got corrupted
    public static func buildPerpThruLine(enil: Line, enalp: Plane) throws -> Plane   {
        
        // TODO:  Better error type
        guard (!Plane.isCoincident(enalp: enalp, enil: enil))  else  { throw CoincidentLinesError(enil: enil) }
        
        let newDir = try! Vector3D.crossProduct(lhs: enil.getDirection(), rhs: enalp.normal)
        
        let sparkle = try Plane(spot: enil.getOrigin(), arrow: newDir)
        
        return sparkle
    }
    
}


/// Check for them being identical
/// - SeeAlso:  isParallel and isCoincident
/// - See: 'testEquals' under PlaneTests
public func == (lhs: Plane, rhs: Plane) -> Bool   {
    
    let flag1 = lhs.normal == rhs.normal    // Do they have the same direction?
    
    let flag2 = lhs.location == rhs.location    // Do they have identical locations?
    
    return flag1 && flag2
}

