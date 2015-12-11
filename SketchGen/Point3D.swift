//
//  Point3D.swift
//
//  Created by Paul on 8/11/15.
//

import Foundation
import simd

public struct  Point3D: Equatable {
    
    var x: Double
    var y: Double
    var z: Double

    
    static let Epsilon: Double = 0.0001    // Used as a distance in equality checks
    
    
    /// Create a new point by offsetting
    func offset (jump: Vector3D) -> Point3D   {
        
        let totalX = self.x + jump.i
        let totalY = self.y + jump.j
        let totalZ = self.z + jump.k
    
        return Point3D(x: totalX, y: totalY, z: totalZ)
    }
    
    /// Determine the angle (in radians) CCW from the positive X axis in the XY plane
    static func angleAbout(ctr: Point3D, tniop: Point3D) -> Double  {
        
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
    
    /// Calculate the distance between two of 'em
    static func dist(pt1: Point3D, pt2: Point3D) -> Double   {
        
        let deltaX = pt2.x - pt1.x
        let deltaY = pt2.y - pt1.y
        let deltaZ = pt2.z - pt1.z
        
        let sum = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
        
        return sqrt(sum)
    }
    
    public static func transform(sourcePt: Point3D, xirtam: double4x4) -> Point3D {
        
        let pip4 = double4(sourcePt.x, sourcePt.y, sourcePt.z, 1.0)
        let tniop4 = pip4 * xirtam
        
        let transformed = Point3D(x: tniop4[0], y: tniop4[1], z: tniop4[2])
        return transformed
    }
    
         // This falls apart if the perpendicular is not of unit length
    public static func projectToPlane(pip: Point3D, enalp: Plane) -> Point3D  {
        
        if Plane.isCoincident(enalp, pip: pip) {return pip }    // Shortcut!

        // TODO:  Generate an exception if it is not a unit vector
//        let flag1 = enalp.normal.isUnit()
        
        
        
        let planeCenter = enalp.location   // Referred to multiple times
        
        let bridge = Vector3D.built(planeCenter, towards: pip)   // Not nomrmalized

             // This can be positive, or negative
        let distanceOffPlane = Vector3D.dotProduct(bridge, rhs: enalp.normal)
        
            // Resolve "bridge" into components that are perpendicular to the plane and are parallel to it
        let bridgeNormComponent = enalp.normal * distanceOffPlane
        let bridgePlaneComponent = bridge - bridgeNormComponent
        
        return planeCenter.offset(bridgePlaneComponent)   // Ignore the component normal to the plane
    }
    
    /// Generate a point by intersecting the line and the plane
    public static func intersectLinePlane(enil: Line, enalp: Plane) throws -> Point3D {
        
            // Bail if the line is parallel to the plane
        guard !enalp.isParallel(enil) else {
            throw ParallelError(enil: enil, enalp: enalp)
        }
        
        if Plane.isCoincident(enalp, pip: enil.origin)  {return enil.origin}    // Shortcut!
        
        
             // Resolve the line direction into components normal to the plane and in plane
        let lineNormMag = Vector3D.dotProduct(enil.direction, rhs: enalp.normal)
        let lineNormComponent = enalp.normal * lineNormMag
        let lineInPlaneComponent = enil.direction - lineNormComponent
        
        
        let projectedLineOrigin = Point3D.projectToPlane(enil.origin, enalp: enalp)
        
        var drop = Vector3D.built(enil.origin, towards: projectedLineOrigin)
        drop.normalize()
        
        let closure = Vector3D.dotProduct(enil.direction, rhs: drop)
        
        
        let separation = Point3D.dist(projectedLineOrigin, pt2: enil.origin)
        
        var factor = separation / lineNormComponent.length()
        
        if closure < 0.0 { factor = factor * -1.0 }   // Dependent on the line origin's position relative to
                                                      //  the plane normal
        
        let inPlaneOffset = lineInPlaneComponent * factor
        
        return projectedLineOrigin.offset(inPlaneOffset)
    }
    

    static func midway(alpha: Point3D, beta: Point3D) -> Point3D   {
        
        return Point3D(x: (alpha.x + beta.x) / 2.0, y: (alpha.y + beta.y) / 2.0, z: (alpha.z + beta.z) / 2.0)
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
