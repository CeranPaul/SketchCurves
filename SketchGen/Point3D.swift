//
//  Point3D.swift
//  SketchCurves
//
//  Created by Paul on 8/11/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Simple representation of a position in space by the use of three orthogonal axes
public struct  Point3D: Hashable {
    
    var x: Double    // Eventually these should be set as private?
    var y: Double
    var z: Double

    /// Threshhold of separation for equality checks
    static let Epsilon: Double = 0.0001
    
    /// Necessary for making Sets
    public var hashValue: Int   {
        
        get  {
            let divX = self.x / Point3D.Epsilon
            let myX = Int(round(divX))
            
            let divY = self.y / Point3D.Epsilon
            let myY = Int(round(divY))
            
            let divZ = self.z / Point3D.Epsilon
            let myZ = Int(round(divZ))
            
            return myX.hashValue + myY.hashValue + myZ.hashValue
        }
    }
    
    
    
    /// Create a new point by offsetting
    /// - See: 'testOffset' under Point3DTests
    /// - SeeAlso:  transform
    public func offset (jump: Vector3D) -> Point3D   {
        
        let totalX = self.x + jump.i
        let totalY = self.y + jump.j
        let totalZ = self.z + jump.k
    
        return Point3D(x: totalX, y: totalY, z: totalZ)
    }
    
    /// Move and scale by a matrix
    /// - SeeAlso:  offset
    public func transform(xirtam: Transform) -> Point3D {
        
        let pip4 = RowMtx4(valOne: self.x, valTwo: self.y, valThree: self.z, valFour: 1.0)
        let tniop4 = pip4 * xirtam
        
        let transformed = tniop4.toPoint()
        return transformed
    }
    
    /// Create a point midway between two others
    public static func midway(alpha: Point3D, beta: Point3D) -> Point3D   {
        
        return Point3D(x: (alpha.x + beta.x) / 2.0, y: (alpha.y + beta.y) / 2.0, z: (alpha.z + beta.z) / 2.0)
    }
    
    
    
    /// Calculate the distance between two of 'em
    /// - See: 'testDist' under Point3DTests
    public static func dist(pt1: Point3D, pt2: Point3D) -> Double   {
        
        let deltaX = pt2.x - pt1.x
        let deltaY = pt2.y - pt1.y
        let deltaZ = pt2.z - pt1.z
        
        let sum = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
        
        return sqrt(sum)
    }
    
    /// Drop the point in the direction opposite of the normal
    public static func projectToPlane(pip: Point3D, enalp: Plane) -> Point3D  {
        
        if Plane.isCoincident(enalp, pip: pip) {return pip }    // Shortcut!
        
        
        let planeCenter = enalp.getLocation()   // Referred to multiple times
        
        let bridge = Vector3D.built(planeCenter, towards: pip)   // Not nomrmalized

             // This can be positive, or negative
        let distanceOffPlane = Vector3D.dotProduct(bridge, rhs: enalp.getNormal())
        
            // Resolve "bridge" into components that are perpendicular to the plane and are parallel to it
        let bridgeNormComponent = enalp.getNormal() * distanceOffPlane
        let bridgeInPlaneComponent = bridge - bridgeNormComponent
        
        return planeCenter.offset(bridgeInPlaneComponent)   // Ignore the component normal to the plane
    }
    
    /// Generate a point by intersecting the line and the plane
    /// - Throws: ParallelError if the input Line is parallel to the plane
    public static func intersectLinePlane(enil: Line, enalp: Plane) throws -> Point3D {
        
            // Bail if the line is parallel to the plane
        guard !enalp.isParallel(enil) else {
            throw ParallelError(enil: enil, enalp: enalp)
        }
        
        if Plane.isCoincident(enalp, pip: enil.getOrigin())  {return enil.getOrigin()}    // Shortcut!
        
        
             // Resolve the line direction into components normal to the plane and in plane
        let lineNormMag = Vector3D.dotProduct(enil.getDirection(), rhs: enalp.getNormal())
        let lineNormComponent = enalp.getNormal() * lineNormMag
        let lineInPlaneComponent = enil.getDirection() - lineNormComponent
        
        
        let projectedLineOrigin = Point3D.projectToPlane(enil.getOrigin(), enalp: enalp)
        
        var drop = Vector3D.built(enil.getOrigin(), towards: projectedLineOrigin)
        drop.normalize()
        
        let closure = Vector3D.dotProduct(enil.getDirection(), rhs: drop)
        
        
        let separation = Point3D.dist(projectedLineOrigin, pt2: enil.getOrigin())
        
        var factor = separation / lineNormComponent.length()
        
        if closure < 0.0 { factor = factor * -1.0 }   // Dependent on the line origin's position relative to
                                                      //  the plane normal
        
        let inPlaneOffset = lineInPlaneComponent * factor
        
        return projectedLineOrigin.offset(inPlaneOffset)
    }
    
    
    /// Determine the angle (in radians) CCW from the positive X axis in the XY plane
    public static func angleAbout(ctr: Point3D, tniop: Point3D) -> Double  {
        
        let vec1 = Vector3D.built(ctr, towards: tniop)    // No need to normalize
        var ang = atan(vec1.j / vec1.i)
        
        if vec1.i < 0.0   {
            
            if vec1.j < 0.0   {
                ang = ang - M_PI
            }  else  {
                ang = ang + M_PI
            }
        }
        
        return ang
    }
    
    /// See if three points could be made into a triangle
    public static func  isThreeUnique(alpha: Point3D, beta: Point3D, gamma: Point3D) -> Bool   {
        
        let flag1 = alpha != beta
        let flag2 = alpha != gamma
        let flag3 = beta != gamma
        
        return flag1 && flag2 && flag3
    }
    
}

/// Check to see that the distance between the two is less than Point3D.Epsilon
public func == (lhs: Point3D, rhs: Point3D) -> Bool   {
    
    let separation = Point3D.dist(lhs, pt2: rhs)
        
    return separation < Point3D.Epsilon
}


/// Verify that the two parameters are distinct points
public func != (lhs: Point3D, rhs: Point3D) -> Bool   {
    
    let separation = Point3D.dist(lhs, pt2: rhs)
        
    return separation >= Point3D.Epsilon
}
