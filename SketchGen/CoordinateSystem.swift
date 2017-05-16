//
//  CoordinateSystem.swift
//  SketchCurves
//
//  Created by Paul on 6/6/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Three coordinates and three orthogonal axes
open class CoordinateSystem   {
    
    var origin: Point3D
    
    var axisX: Vector3D
    var axisY: Vector3D
    var axisZ: Vector3D
    
    
    /// Construct an equivalent to the global CSYS
    /// Can be changed by static function "relocate"
    init()   {
        
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
    init(spot: Point3D, alpha: Vector3D, beta: Vector3D, gamma: Vector3D) throws   {
        
        self.origin = spot
        
        self.axisX = alpha
        self.axisY = beta
        self.axisZ = gamma
        
        guard (axisX.isUnit()) else {  throw NonUnitDirectionError(dir: self.axisX) }
        guard (axisY.isUnit()) else {  throw NonUnitDirectionError(dir: self.axisY) }
        guard (axisZ.isUnit()) else {  throw NonUnitDirectionError(dir: self.axisZ) }
        
        guard (CoordinateSystem.isMutOrtho(uno: axisX, dos: axisY, tres: axisZ)) else { throw NonOrthogonalCSYSError() }
        
    }
    
    /// Generate from two vectors and a point
    /// - Parameters:
    ///   - spot: Point to serve as the origin
    ///   - direction1: A Vector3D
    ///   - direction2: A Vector3D that is not parallel or opposite to direction1
    ///   - useFirst: Use the first input vector as the reference direction?
    ///   - verticalRef: Does the reference direction represent vertical or horizontal in the base plane?
    init(spot: Point3D, direction1: Vector3D, direction2: Vector3D, useFirst: Bool, verticalRef: Bool)   {
        
        var outOfPlane = try! Vector3D.crossProduct(lhs: direction1, rhs: direction2)
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
    
    
    /// Generate a Transform to rotate and translate TO the global coordinate system
    /// Should this become a method of Transform?
    public func genToGlobal() -> Transform   {
        
        let rotate = Transform(localX: self.axisX, localY: self.axisY, localZ: self.axisZ)
        let translate = Transform(deltaX: self.origin.x, deltaY: self.origin.y, deltaZ: self.origin.z)
        
        let tform = rotate * translate
        
        return tform
    }
    
    /// Generate a Transform to get points FROM the global CSYS
    /// Should this become a method of Transform?
    public func genFromGlobal() -> Transform   {
        
           // Construct the transpose of the 3 x 3
        let newA = self.axisX.i
        let newB = self.axisY.i
        let newC = self.axisZ.i
        let newD = 0.0
        
        let newE = self.axisX.j
        let newF = self.axisY.j
        let newG = self.axisZ.j
        let newH = 0.0
        
        let newJ = self.axisX.k
        let newK = self.axisY.k
        let newM = self.axisZ.k
        let newN = 0.0
        
        let newP = 0.0
        let newR = 0.0
        let newS = 0.0
        let newT = 1.0
        
        let transpose = Transform(a: newA, b: newB, c: newC, d: newD, e: newE, f: newF, g: newG, h: newH, j: newJ, k: newK, m: newM, n: newN, p: newP, r: newR, s: newS, t: newT)
        
        let rowOrig = RowMtx4(ptIn: self.origin)
        
        
        let flippedOrig = rowOrig * transpose
        
        let invertedTranslate = Transform(deltaX: -1.0 * flippedOrig.a, deltaY: -1.0 * flippedOrig.b, deltaZ: -1.0 * flippedOrig.c)
        
        let tform = transpose * invertedTranslate
        
        return tform
    }
    
    
    /// Check to see that these three vectors are mutually orthogonal
    /// - Parameters:
    ///   - uno: Unit vector to serve as an axis
    ///   - dos: Another unit vector
    ///   - tres: The final unit vector
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
    /// Should this become another initializer?
    public static func relocate(startingCSYS: CoordinateSystem, betterOrigin: Point3D) -> CoordinateSystem   {
        
        let sparkling = try! CoordinateSystem(spot: betterOrigin, alpha: startingCSYS.axisX, beta: startingCSYS.axisY, gamma: startingCSYS.axisZ)
        
        return sparkling
    }
    
}
