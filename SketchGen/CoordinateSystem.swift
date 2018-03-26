//
//  CoordinateSystem.swift
//  SketchCurves
//
//  Created by Paul on 6/6/16.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Three coordinates and three orthogonal axes
open class CoordinateSystem   {
    
    /// Can be changed with 'relocate' function
    var origin: Point3D
    
       // To assure the property of being mutually orthogonal
    var axisX: Vector3D
    var axisY: Vector3D
    var axisZ: Vector3D
    
    
    /// Construct an equivalent to the global CSYS.
    /// Origin can be changed by static function 'relocate'.
    /// - See: 'testFidelity1' under CoordinateSystemTests
    public init()   {
        
        self.origin = Point3D(x: 0.0, y: 0.0, z: 0.0)
        self.axisX = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        self.axisY = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        self.axisZ = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
    }
    
    
    /// Construct from a point and three vectors
    /// - Parameters:
    ///   - spot: The origin of the CSYS
    ///   - alpha: A unit vector representing an axis
    ///   - beta: Another unit vector - orthogonal to others
    ///   - gamma: Final unit vector
    /// - Throws:
    ///   - NonUnitDirectionError for any bad input vector
    ///   - NonOrthogonalCSYSError if the inputs, as a set, aren't good
    /// - See: 'testFidelity2' under CoordinateSystemTests
    public init(spot: Point3D, alpha: Vector3D, beta: Vector3D, gamma: Vector3D) throws   {
        
        self.origin = spot
        
        guard (alpha.isUnit()) else {  throw NonUnitDirectionError(dir: alpha) }
        self.axisX = alpha
        
        guard (beta.isUnit()) else {  throw NonUnitDirectionError(dir: beta) }
        self.axisY = beta
        
        guard (gamma.isUnit()) else {  throw NonUnitDirectionError(dir: gamma) }
        self.axisZ = gamma
        
        
        guard (CoordinateSystem.isMutOrtho(uno: axisX, dos: axisY, tres: axisZ)) else { throw NonOrthogonalCSYSError() }
        
    }
    
    /// Generate from two vectors and a point.
    /// - Parameters:
    ///   - spot: Point to serve as the origin
    ///   - direction1: A Vector3D
    ///   - direction2: A Vector3D that is not parallel or opposite to direction1
    ///   - useFirst: Use the first input vector as the reference direction?
    ///   - verticalRef: Does the reference direction represent vertical or horizontal in the local plane?
    /// - Throws:
    ///   - NonUnitDirectionError for any bad input vector
    /// - See: 'testFidelity3' under CoordinateSystemTests
    public init(spot: Point3D, direction1: Vector3D, direction2: Vector3D, useFirst: Bool, verticalRef: Bool) throws   {
        
        guard (direction1.isUnit()) else {  throw NonUnitDirectionError(dir: direction1) }
        guard (direction2.isUnit()) else {  throw NonUnitDirectionError(dir: direction2) }

        
        var outOfPlane = try Vector3D.crossProduct(lhs: direction1, rhs: direction2)
        outOfPlane.normalize()
        
        self.axisZ = outOfPlane
        
        
        if useFirst   {
            
            if verticalRef   {
                self.axisY = direction1
                self.axisX = try! Vector3D.crossProduct(lhs: self.axisY, rhs: self.axisZ)
            }  else  {
                self.axisX = direction1
                self.axisY = try! Vector3D.crossProduct(lhs: self.axisZ, rhs: self.axisX)
            }
            
        }  else  {
            
            if verticalRef   {
                self.axisY = direction2
                self.axisX = try! Vector3D.crossProduct(lhs: self.axisY, rhs: self.axisZ)
            }  else  {
                self.axisX = direction2
                self.axisY = try! Vector3D.crossProduct(lhs: self.axisZ, rhs: self.axisX)
            }
        }
        
        self.origin = spot
    }
    
    
    public func getOrigin() -> Point3D   {
        
        return origin
    }
    
    
    public func getAxisX() -> Vector3D   {
        
        return axisX
        
    }
    
    
    public func getAxisY() -> Vector3D   {
        
        return axisY
        
    }
    
    
    public func getAxisZ() -> Vector3D   {
        
        return axisZ
        
    }
    
    
    /// Check to see that these three vectors are mutually orthogonal
    /// - Parameters:
    ///   - uno: Unit vector to serve as an axis
    ///   - dos: Another unit vector
    ///   - tres: The final unit vector
    ///   Returns: Simple flag
    /// - See: 'testIsMutOrtho' under CoordinateSystemTests
    public static func isMutOrtho(uno: Vector3D, dos: Vector3D, tres: Vector3D) -> Bool   {
        
        let dot12 = Vector3D.dotProduct(lhs: uno, rhs: dos)
        let flag1 = abs(dot12) < Vector3D.EpsilonV
        
        let dot23 = Vector3D.dotProduct(lhs: dos, rhs: tres)
        let flag2 = abs(dot23) < Vector3D.EpsilonV
        
        let dot31 = Vector3D.dotProduct(lhs: tres, rhs: uno)
        let flag3 = abs(dot31) < Vector3D.EpsilonV
        
        return flag1 && flag2 && flag3
    }
    
    
    /// Create from an existing CSYS, but use a different origin
    /// - Parameters:
    ///   - startingCSYS: Desired set of orientations
    ///   - betterOrigin: New location
    /// - See: 'testRelocate' under CoordinateSystemTests
    public static func relocate(startingCSYS: CoordinateSystem, betterOrigin: Point3D) -> CoordinateSystem   {
        
        let sparkling = try! CoordinateSystem(spot: betterOrigin, alpha: startingCSYS.axisX, beta: startingCSYS.axisY, gamma: startingCSYS.axisZ)
        
        return sparkling
    }
    
}

/// Check for them being identical
public func == (lhs: CoordinateSystem, rhs: CoordinateSystem) -> Bool   {
    
    let flagOrig = (lhs.getOrigin() == rhs.getOrigin())
    
    let flagX = (lhs.getAxisX() == rhs.getAxisX())
    let flagY = (lhs.getAxisY() == rhs.getAxisY())
    let flagZ = (lhs.getAxisZ() == rhs.getAxisZ())
    
    return flagOrig && flagX && flagY && flagZ
}
