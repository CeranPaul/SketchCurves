//
//  Plane.swift
//  SketchCurves
//
//  Created by Paul on 8/11/15.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Unbounded flat surface
public struct Plane   {
    
    /// A point to locate the plane
    internal var location: Point3D
    
    /// A vector perpendicular to the plane
    internal var normal: Vector3D
    
    
    /// Records parameters and checks to see that the normal is a legitimate vector
    /// - Parameters:
    ///   - alpha:  Origin for the fresh plane
    ///   - arrow:  Unit vector that the plane will be perpendicular to
    /// - See: 'testFidelity' under PlaneTests
    public init(spot: Point3D, arrow: Vector3D) throws  {
        
        guard !arrow.isZero()  else  { throw ZeroVectorError(dir: arrow) }
        guard arrow.isUnit()  else  { throw NonUnitDirectionError(dir: arrow) }
        
        self.location = spot
        self.normal = arrow
        
    }
    
    /// Construct a plane from three points
    /// - Parameters:
    ///   - alpha:  First input point and origin of the fresh plane
    ///   - beta:  Second input point
    ///   - gamma:  Third input point
    /// - Returns: Fresh plane
    /// - Throws: CoincidentPointsError for duplicate or linear inputs
    /// - See: 'testInitPts' under PlaneTests
    init(alpha: Point3D, beta: Point3D, gamma: Point3D) throws   {
        
        guard Point3D.isThreeUnique(alpha: alpha, beta: beta, gamma: gamma)  else  { throw CoincidentPointsError(dupePt: alpha) }
        
        // TODO: Come up with a better error type
        guard !Point3D.isThreeLinear(alpha: alpha, beta: beta, gamma: gamma)  else  { throw CoincidentPointsError(dupePt: alpha) }
        
        
        self.location = alpha
        
        let thisWay = Vector3D.built(from: alpha, towards: beta)
        let thatWay = Vector3D.built(from: alpha, towards: gamma)
        
        var perpTo = try! Vector3D.crossProduct(lhs: thisWay, rhs: thatWay)
        perpTo.normalize()
        
        self.normal = perpTo

    }
    
    // TODO: Write a constructor from two lines, and possibly a line and a point.

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
    
    
    /// Build orthogonal vectors from the origin of the plane to the point
    /// - Parameters:
    ///   - pip:  Point of interest
    /// - Returns: Tuple of Vectors
    /// - See: 'testResolveRelative' under PlaneTests
    public func resolveRelativeVec(pip: Point3D) -> (inPlane: Vector3D, perp: Vector3D)   {
        
        let bridge = Vector3D.built(from: self.location, towards: pip)
        
        let along = Vector3D.dotProduct(lhs: bridge, rhs: self.normal)
        let perp = self.normal * along
        
        let inPlane = bridge - perp
        
        return (inPlane, perp)
    }
    
    
    /// Check to see that the line direction is perpendicular to the normal
    /// - Parameters:
    ///   - flat:  Reference plane
    ///   - enil:  Line for testing
    /// - Returns: Simple flag
    /// - See: 'testIsParallelLine' under PlaneTests
    public static func isParallel(flat: Plane, enil: Line) -> Bool   {
        
        let perp = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: flat.normal)
        
        return abs(perp) < Vector3D.EpsilonV
    }
    
    /// Check to see that the line is parallel to the plane, and lies on it
    /// - Parameters:
    ///   - enalp:  Reference plane
    ///   - enil:  Line for testing
    /// - Returns: Simple flag
    /// - See: 'testIsCoincidentLine' under PlaneTests
    public static func isCoincident(enalp: Plane, enil: Line) -> Bool  {
        
        return self.isParallel(flat: enalp, enil: enil) && Plane.isCoincident(flat: enalp, pip: enil.getOrigin())
    }
    
    
    /// Does the argument point lie on the plane?
    /// - Parameters:
    ///   - flat:  Plane for testing
    ///   - pip:  Point for testing
    /// - Returns: Simple flag
    /// - See: 'testIsCoincident' under PlaneTests
    public static func isCoincident(flat: Plane, pip:  Point3D) -> Bool  {
        
        if pip == flat.getLocation()   {  return true  }   // Shortcut!
        
        let bridge = Vector3D.built(from: flat.location, towards: pip)
        
        // This can be positive, negative, or zero
        let distanceOffPlane = Vector3D.dotProduct(lhs: bridge, rhs: flat.normal)
        
        return  abs(distanceOffPlane) < Point3D.Epsilon
    }
    
    /// Are the normals either parallel or opposite?
    /// - Parameters:
    ///   - lhs:  One plane for testing
    ///   - rhs:  Another plane for testing
    /// - Returns: Simple flag
    /// - SeeAlso:  isCoincident and ==
    /// - See: 'testIsParallelPlane' under PlaneTests
    public static func isParallel(lhs: Plane, rhs: Plane) -> Bool{
        
        return lhs.normal == rhs.normal || Vector3D.isOpposite(lhs: lhs.normal, rhs: rhs.normal)
    }
    
    /// Planes are parallel, and rhs location lies on lhs
    /// - Parameters:
    ///   - lhs:  One plane for testing
    ///   - rhs:  Another plane for testing
    /// - Returns: Simple flag
    /// - SeeAlso:  isParallel and ==
    /// - See: 'testIsCoincidentPlane' under PlaneTests
    public static func isCoincident(lhs: Plane, rhs: Plane) -> Bool  {
        
        return Plane.isCoincident(flat: lhs, pip: rhs.location) && Plane.isParallel(lhs: lhs, rhs: rhs)
    }
    
    
    /// Construct a parallel plane offset some distance.
    /// - Parameters:
    ///   - base:  The reference plane
    ///   - offset:  Desired separation. Can be positive or negative.
    ///   - reverse:  Flip the normal, or not
    /// - Returns: Fresh plane that has separation
    /// - See: 'testBuildParallel' under PlaneTests
    public static func buildParallel(base: Plane, offset: Double, reverse: Bool) -> Plane  {
    
        let jump = base.normal * offset    // Offset could be a negative number
        
        let origPoint = base.location
        let newLoc = origPoint.offset(jump: jump)
        
        
        var newNorm = base.normal
        
        if reverse   {
            newNorm = base.normal * -1.0
        }
        
        let sparkle =  try! Plane(spot: newLoc, arrow: newNorm)   // Allowable because the new normal mimics the original
    
        return sparkle
    }
    
    
    /// Construct a new plane perpendicular to an existing plane, and through a line on that plane
    /// Normal could be the opposite of what you hoped for
    /// - Parameters:
    ///   - enil:  Location for a fresh plane
    ///   - enalp:  The reference plane
    /// - Returns: Fresh plane
    /// - Throws:
    ///   - CoincidentLinesError if line doesn't lie on the plane
    /// - See: 'testBuildPerpThruLine' under PlaneTests
    public static func buildPerpThruLine(enil: Line, enalp: Plane) throws -> Plane   {
        
        // TODO:  Better error type
        guard Plane.isCoincident(enalp: enalp, enil: enil)  else  { throw CoincidentLinesError(enil: enil) }
        
        let newDir = try! Vector3D.crossProduct(lhs: enil.getDirection(), rhs: enalp.normal)
        
        let sparkle = try Plane(spot: enil.getOrigin(), arrow: newDir)
        
        return sparkle
    }
    
    /// Generate a point by intersecting a line and a plane
    /// - Parameters:
    ///   - enil:  Line of interest
    ///   - enalp:  Flat surface to hit
    /// - Returns: Common Point
    /// - Throws: ParallelError if the input Line is parallel to the plane
    /// - See: 'testIntersectLinePlane' under PlaneTests
    public static func intersectLinePlane(enil: Line, enalp: Plane) throws -> Point3D {
        
        // Bail if the line is parallel to the plane
        guard !Plane.isParallel(flat: enalp, enil: enil) else { throw ParallelError(enil: enil, enalp: enalp) }
        
        if Plane.isCoincident(flat: enalp, pip: enil.getOrigin())  { return enil.getOrigin() }    // Shortcut!
        
        
        // Resolve the line direction into components normal to the plane and in plane
        let lineNormMag = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: enalp.getNormal())
        let lineNormComponent = enalp.getNormal() * lineNormMag
        let lineInPlaneComponent = enil.getDirection() - lineNormComponent
        
        
        let projectedLineOrigin = Plane.projectToPlane(pip: enil.getOrigin(), enalp: enalp)
        
        let drop = Vector3D.built(from: enil.getOrigin(), towards: projectedLineOrigin, unit: true)
        
        let closure = Vector3D.dotProduct(lhs: enil.getDirection(), rhs: drop)
        
        
        let separation = Point3D.dist(pt1: projectedLineOrigin, pt2: enil.getOrigin())
        
        var factor = separation / lineNormComponent.length()
        
        if closure < 0.0 { factor = factor * -1.0 }   // Dependent on the line origin's position relative to
        //  the plane normal
        
        let inPlaneOffset = lineInPlaneComponent * factor
        
        return projectedLineOrigin.offset(jump: inPlaneOffset)
    }
    
    
    /// Construct a line by intersecting two planes
    /// - Parameters:
    ///   - flatA:  First plane
    ///   - flatB:  Second plane
    /// - Throws: ParallelPlanesError if the inputs are parallel
    /// - Throws: CoincidentPlanesError if the inputs are coincident
    /// - See: 'testIntersectPlanes' under PlaneTests
    public static func intersectPlanes(flatA: Plane, flatB: Plane) throws -> Line   {
        
        guard !Plane.isCoincident(lhs: flatA, rhs: flatB)  else  { throw CoincidentPlanesError(enalpA: flatA) }
        
        guard !Plane.isParallel(lhs: flatA, rhs: flatB)  else  { throw ParallelPlanesError(enalpA: flatA) }
        
        
        /// Direction of the intersection line
        var lineDir = try! Vector3D.crossProduct(lhs: flatA.getNormal(), rhs: flatB.getNormal())
        lineDir.normalize()   // Checks in crossProduct should keep this from being a zero vector
        
        /// Vector on plane B that is perpendicular to the intersection line
        var perpInB = try! Vector3D.crossProduct(lhs: lineDir, rhs: flatB.getNormal())
        perpInB.normalize()   // Checks in crossProduct should keep this from being a zero vector
        
        // The ParallelPlanesError or CoincidentPlanesError should be avoided by the guard statements
        
        let lineFromCenterB =  try Line(spot: flatB.getLocation(), arrow: perpInB)  // Can be either towards flatA,
        // or away from it
        
        let intersectionPoint = try Plane.intersectLinePlane(enil: lineFromCenterB, enalp: flatA)
        let common = try Line(spot: intersectionPoint, arrow: lineDir)
        
        return common
    }
    
    /// Drop the point in the direction opposite of the normal
    /// - Parameters:
    ///   - pip:  Point to be projected
    ///   - enalp:  Flat surface to hit
    /// - Returns: Closest point on plane
    /// - See: 'testProjectToPlane' under PlaneTests
    public static func projectToPlane(pip: Point3D, enalp: Plane) -> Point3D  {
        
        if Plane.isCoincident(flat: enalp, pip: pip) {return pip }    // Shortcut!
        
        let planeCenter = enalp.getLocation()   // Referred to multiple times
        
        let bridge = Vector3D.built(from: planeCenter, towards: pip)   // Not normalized
        
        // This can be positive, or negative
        let distanceOffPlane = Vector3D.dotProduct(lhs: bridge, rhs: enalp.getNormal())
        
        // Resolve "bridge" into components that are perpendicular to the plane and are parallel to it
        let bridgeNormComponent = enalp.getNormal() * distanceOffPlane
        let bridgeInPlaneComponent = bridge - bridgeNormComponent
        
        return planeCenter.offset(jump: bridgeInPlaneComponent)   // Ignore the component normal to the plane
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

