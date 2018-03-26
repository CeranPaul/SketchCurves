//
//  Point3D.swift
//  SketchCurves
//
//  Created by Paul on 8/11/15.
//  Copyright © 2018 Ceran Digital Media. See LICENSE.md
//

import UIKit

/// Simple representation of a position in space by the use of three orthogonal coordinates
/// The default initializer suffices
public struct  Point3D: Hashable {
    
    var x: Double    // Eventually these should be set as private?
    var y: Double
    var z: Double

    
    /// Threshhold of separation for equality checks
    public static let Epsilon: Double = 0.0001
    
    
    
    /// Create a new point by offsetting.
    /// Should this become an overloaded addition function between a Point and Vector?
    /// - Parameters:
    ///   - jump:  Vector to be used as the offset
    /// - Returns: A new Point not too far away.
    /// - SeeAlso:  transform
    /// - See: 'testOffset' under Point3DTests
    public func offset (jump: Vector3D) -> Point3D   {
        
        let totalX = self.x + jump.i
        let totalY = self.y + jump.j
        let totalZ = self.z + jump.k
    
        return Point3D(x: totalX, y: totalY, z: totalZ)
    }
    
    /// Move, rotate, and/or scale by a matrix.
    /// This could be alternately written as an overloaded multiplication function.
    /// The approach used here gives up polymorphism.
    /// - Parameters:
    ///   - pip:  The original point
    ///   - xirtam:  Matrix for the intended transformation
    /// - Returns: A new Point.
    /// - SeeAlso:  offset
    public static func transform(pip: Point3D, xirtam: Transform) -> Point3D {
        
        let pip4 = RowMtx4(valOne: pip.x, valTwo: pip.y, valThree: pip.z, valFour: 1.0)
        let tniop4 = pip4 * xirtam
        
        let transformed = tniop4.toPoint()
        return transformed
    }
    
    
    /// Calculate the distance between two of 'em.
    /// Should this become an overloaded subtract function?
    /// - Parameters:
    ///   - pt1:  One point.
    ///   - pt2:  Another point.
    /// - Returns: Always positive Double.
    /// - See: 'testDist' under Point3DTests
    public static func dist(pt1: Point3D, pt2: Point3D) -> Double   {
        
        let deltaX = pt2.x - pt1.x
        let deltaY = pt2.y - pt1.y
        let deltaZ = pt2.z - pt1.z
        
        let sum = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
        
        return sqrt(sum)
    }
    
    
    /// Create a point midway between two others.
    /// - Parameters:
    ///   - alpha:  One boundary
    ///   - beta:  The other boundary
    /// - Returns: A Point in the middle.
    /// - See: 'testMidway' under Point3DTests
    public static func midway(alpha: Point3D, beta: Point3D) -> Point3D   {
        
        return Point3D(x: (alpha.x + beta.x) / 2.0, y: (alpha.y + beta.y) / 2.0, z: (alpha.z + beta.z) / 2.0)
    }
    
    
    /// Determine the angle (in radians) CCW from the positive X axis in the XY plane.
    /// - Parameters:
    ///   - ctr:  Reference origin
    ///   - tniop:  Point of interest
    /// - Returns: Angle in radians.
    /// - See: 'testAngleAbout' under Point3DTests
   public static func angleAbout(ctr: Point3D, tniop: Point3D) -> Double  {
        
        let vec1 = Vector3D.built(from: ctr, towards: tniop)    // No need to normalize
        var ang = atan(vec1.j / vec1.i)
        
        if vec1.i < 0.0   {
            
            if vec1.j < 0.0   {
                ang = ang - Double.pi
            }  else  {
                ang = ang + Double.pi
            }
        }
        
        return ang
    }
    
    
    /// Check if three points have no duplicates.  Useful for building triangles, or defining arcs.
    /// - Parameters:
    ///   - alpha:  A test point
    ///   - beta:  Another test point
    ///   - gamma:  The final test point
    /// - Returns: A simple flag.
    /// - See: 'testIsThreeUnique' under Point3DTests
    public static func  isThreeUnique(alpha: Point3D, beta: Point3D, gamma: Point3D) -> Bool   {
        
        let flag1 = alpha != beta
        let flag2 = alpha != gamma
        let flag3 = beta != gamma
        
        return flag1 && flag2 && flag3
    }
    
    
    /// See if three points are all in a line.
    /// 'isThreeUnique' should pass before running this.
    /// - Parameters:
    ///   - alpha:  A test point
    ///   - beta:  Another test point
    ///   - gamma:  The final test point
    /// - Returns: A simple flag.
    /// - SeeAlso:  isThreeUnique
    /// - See: 'testIsThreeLinear' under Point3DTests
    public static func isThreeLinear(alpha: Point3D, beta: Point3D, gamma: Point3D) -> Bool   {
        
        let thisWay = Vector3D.built(from: alpha, towards: beta)
        let thatWay = Vector3D.built(from: alpha, towards: gamma)

        let flag1 = try! Vector3D.isScaled(lhs: thisWay, rhs: thatWay)
        
        return flag1
    }
    
    
    /// Check if all contained points are unique
    /// Not suitable for large arrays - n factorial
    public static func uniqueChain(chain: [Point3D]) -> Bool   {
        
        /// All points have adequate separation
        var flag = true
        
        for (index, pip) in chain.enumerated()   {
            
            for g in index + 1..<chain.count   {
                
                let sep = Point3D.dist(pt1: pip, pt2: chain[g])
                
                if sep < self.Epsilon   {
                    
                    flag = false
                    break
                }
                
            }
            
        }
        
        return flag
    }
    
    /// Throw away the Z value and convert
    /// Should this become a computed member variable?
    /// - Returns: A CGPoint.
    /// - See: 'testMakeCGPoint' under Point3DTests
    public static func makeCGPoint(pip: Point3D) -> CGPoint   {
        
        return CGPoint(x: pip.x, y: pip.y)
    }
    
    
    /// Check to see that the distance between the two is less than Point3D.Epsilon.
    /// - See: 'testEqual' under Point3DTests
    public static func == (lhs: Point3D, rhs: Point3D) -> Bool   {
        
        let separation = Point3D.dist(pt1: lhs, pt2: rhs)   // Always positive
        
        return separation < Point3D.Epsilon
    }
    
    
    /// Necessary for making Sets
    /// - See: 'testHashValue' under Point3DTests
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
    
}


