//
//  CoordinateSystem.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 6/6/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Three dimensions with orthogonal axes
public class CoordinateSystem   {
    
    var origin: Point3D
    
    var axisX: Vector3D
    var axisY: Vector3D
    var axisZ: Vector3D
    
    /// Construct an equivalent to the global CSYS
    init()   {
        
        self.origin = Point3D(x: 0.0, y: 0.0, z: 0.0)
        self.axisX = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        self.axisY = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        self.axisZ = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
    }
    
    /// Construct from a point and three vectors
    /// - Throws: 
    /// - NonUnitDirectionError for bad input vector
    /// - NonOrthogonalCSYSError for bad set of inputs
    init(spot: Point3D, alpha: Vector3D, beta: Vector3D, gamma: Vector3D) throws   {
        
        self.origin = spot
        
        self.axisX = alpha
        self.axisY = beta
        self.axisZ = gamma
        
        guard (axisX.isUnit()) else {  throw NonUnitDirectionError(dir: self.axisX)  }
        guard (axisY.isUnit()) else {  throw NonUnitDirectionError(dir: self.axisY)  }
        guard (axisZ.isUnit()) else {  throw NonUnitDirectionError(dir: self.axisZ)  }
        
        guard (CoordinateSystem.isMutOrtho(axisX, dos: axisY, tres: axisZ)) else {  throw NonOrthogonalCSYSError() }
        
    }
    
    /// Generate from two vectors and a point
    /// - Parameters:
    ///   - direction1: A Vector3D
    ///   - direction2: A Vector3D that is not parallel or opposite to direction1
    ///   - useFirst: Use the first input vector as the reference direction?
    ///   - verticalRef: Does the reference direction represent vertical or horizontal in the base plane?
    ///   - spot: Point to serve as the origin
    init(direction1: Vector3D, direction2: Vector3D, useFirst: Bool, verticalRef: Bool, spot: Point3D)   {
        
        var outOfPlane = try! Vector3D.crossProduct(direction1, rhs: direction2)
        try! outOfPlane.normalize()
        
        self.axisZ = outOfPlane
        
        if useFirst   {
            
            if verticalRef   {
                self.axisY = direction1
                self.axisX = try! Vector3D.crossProduct(self.axisY, rhs: self.axisZ)
            }  else  {
                self.axisX = direction1
                self.axisY = try! Vector3D.crossProduct(self.axisZ, rhs: self.axisX)
            }
            
        }  else  {
            
            if verticalRef   {
                self.axisY = direction2
                self.axisX = try! Vector3D.crossProduct(self.axisY, rhs: self.axisZ)
            }  else  {
                self.axisX = direction2
                self.axisY = try! Vector3D.crossProduct(self.axisZ, rhs: self.axisX)
            }
        }
        
        self.origin = spot
    }
    
    /// Check to see that these three vectors are mutually orthogonal
    public static func isMutOrtho(uno: Vector3D, dos: Vector3D, tres: Vector3D) -> Bool   {
        
        let dot12 = Vector3D.dotProduct(uno, rhs: dos)
        let flag1 = abs(dot12) < Vector3D.EpsilonV
        
        let dot23 = Vector3D.dotProduct(dos, rhs: tres)
        let flag2 = abs(dot23) < Vector3D.EpsilonV
        
        let dot31 = Vector3D.dotProduct(tres, rhs: uno)
        let flag3 = abs(dot31) < Vector3D.EpsilonV
        
        return flag1 && flag2 && flag3
    }
    
    
    
    /// Generate a Transform to rotate and translate to the global coordinate system
    /// Should this become a method of Transform?
    func genToGlobal() -> Transform   {
        
        let rotate = Transform(localX: self.axisX, localY: self.axisY, localZ: self.axisZ)
        let translate = Transform(deltaX: self.origin.x, deltaY: self.origin.y, deltaZ: self.origin.z)
        
        let tform = rotate * translate
        
        return tform
    }
    
    /// Generate a Transform to get points from the global CSYS
    /// Should this become a method of Transform?
    func genFromGlobal() -> Transform   {
        
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
    
    /// Create a duplicate with a different origin
    public static func relocate(originalCSYS: CoordinateSystem, betterOrigin: Point3D) -> CoordinateSystem   {
        
        let sparkling = try! CoordinateSystem(spot: betterOrigin, alpha: originalCSYS.axisX, beta: originalCSYS.axisY, gamma: originalCSYS.axisZ)
        
        return sparkling
    }
}
