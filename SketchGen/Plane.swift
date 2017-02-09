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
        
        self.location = spot
        self.normal = arrow        // TODO:  Include a test to verify that the errors get thrown correctly

        
        // In an 'init', this cannot be done at the top
        guard (!self.normal.isZero()) else  {throw ZeroVectorError(dir: self.normal)}
        guard (self.normal.isUnit()) else  {throw NonUnitDirectionError(dir: self.normal)}
    }
    
    /// Generate a vector from differences between the inputs
    /// Normal could be the opposite of what you hoped for
    /// - Throws: CoincidentPointsError for duplicate or linear inputs
    init(alpha: Point3D, beta: Point3D, gamma: Point3D) throws   {
        
        self.location = alpha
        self.normal = Vector3D(i: 0.6, j: 0.6, k: 0.6)
        
        guard (Point3D.isThreeUnique(alpha: alpha, beta: beta, gamma: gamma)) else { throw CoincidentPointsError(dupePt: alpha)}
        
        // TODO: Come up with a better error type
        guard (!Point3D.isThreeLinear(alpha: alpha, beta: beta, gamma: gamma))  else  {  throw CoincidentPointsError(dupePt: alpha)}
            
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
    
    
    /// Does the argument point lie on the plane?
    /// - See: 'testIsCoincident' under PlaneTests
    public static func isCoincident(_ flat: Plane, pip:  Point3D) -> Bool  {
        
        if pip == flat.getLocation()   {  return true  }   // Shortcut!
        
        let bridge = Vector3D.built(from: flat.location, towards: pip)
        
        // This can be positive, negative, or zero
        let distanceOffPlane = Vector3D.dotProduct(lhs: bridge, rhs: flat.normal)  
        
        return  abs(distanceOffPlane) < Point3D.Epsilon
    }
    
    
    /// Check to see that the line direction is perpendicular to the normal
    func isParallel(_ enil: Line) -> Bool   {
        
        let perp = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: self.normal)
        
        return abs(perp) < Vector3D.EpsilonV
    }
    
    /// Check to see that the line is parallel to the plane, and lies on it
    func isCoincident(_ enil: Line) -> Bool  {
        
        return self.isParallel(enil) && Plane.isCoincident(self, pip: enil.getOrigin())
    }
    
    
    
    /// Are the normals either parallel or opposite?
    /// - SeeAlso:  isCoincident and ==
    public static func isParallel(_ lhs: Plane, rhs: Plane) -> Bool{
        
        return lhs.normal == rhs.normal || Vector3D.isOpposite(lhs: lhs.normal, rhs: rhs.normal)
    }
    
    /// Planes are parallel, and rhs location lies on lhs
    /// - SeeAlso:  isParallel and ==
    public static func isCoincident(_ lhs: Plane, rhs: Plane) -> Bool  {
        
        return Plane.isCoincident(lhs, pip: rhs.location) && Plane.isParallel(lhs, rhs: rhs)
    }
    
    /// Construct a parallel plane offset some distance
    public static func buildParallel(_ base: Plane, offset: Double, reverse: Bool) throws -> Plane  {
    
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
    public static func buildPerpThruLine(_ enil:  Line, enalp: Plane) throws -> Plane   {
        
        // TODO:  Ensure that the input line is in the plane
        let newDir = try! Vector3D.crossProduct(lhs: enil.getDirection(), rhs: enalp.normal)
        
        return try Plane(spot: enil.getOrigin(), arrow: newDir)
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

