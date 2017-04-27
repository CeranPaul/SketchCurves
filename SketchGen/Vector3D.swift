//
//  Vector3D.swift
//  SketchCurves
//
//  Created by Paul on 8/11/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// A direction built from three orthogonal components
/// Default constructor suffices
public struct Vector3D: Equatable {
    
    var i: Double
    var j: Double
    var k: Double
    
    /// Difference limit between components in equality checks
    static let EpsilonV: Double = 0.0001

    
    
    /// Destructively make this a unit vector
    /// - See: 'testNormalize' under Vector3DTests
    public mutating func normalize()   {
        
        if !self.isZero()   {
        
            let denom = self.length()
            
            i = self.i / denom
            j = self.j / denom
            k = self.k / denom
        }
    }
    
    /// Figure the combined length of all three components
    /// - See: 'testLength' under Vector3DTests
    public func length() -> Double {
        
        return sqrt(self.i * self.i + self.j * self.j + self.k * self.k)
    }
    
    
    /// Check to see if the vector has zero length
    /// - See: 'testIsZero' under Vector3DTests
    public func isZero() -> Bool   {
        
        let flagI = abs(self.i)  < Vector3D.EpsilonV
        let flagJ = abs(self.j)  < Vector3D.EpsilonV
        let flagK = abs(self.k)  < Vector3D.EpsilonV
        
        return flagI && flagJ && flagK
    }
    
    /// Check to see if this is a unit vector
    /// - See: 'testIsUnit' under Vector3DTests
    public func isUnit() -> Bool   {
        
        return abs(self.length() - 1.0) < Vector3D.EpsilonV
    }
    

    /// Construct a vector with the opposite direction
    /// - See: 'testReverse' under Vector3DTests
    public func reverse() -> Vector3D   {
        
        let ricochet = Vector3D(i: self.i * -1.0, j: self.j * -1.0, k: self.k * -1.0)
        return ricochet
    }
    
    
    /// Rotate by a matrix
    /// - See: 'testTransform' under Vector3DTests
    public func transform(xirtam: Transform) -> Vector3D {
        
        let dir4 = RowMtx4(valOne: self.i, valTwo: self.j, valThree: self.k, valFour: 0.0)
        let vec4 = dir4 * xirtam
        
        let transformed = vec4.toVector()
        return transformed
    }
    
    
    /// Construct a vector that has been rotated from self about the axis specified by the first argument
    /// - Parameter:  angleRad  The amount that the direction should change  Expressed in radians, not degrees!
    func twistAbout(axisDir: Vector3D, angleRad: Double) -> Vector3D  {   // Should this become a static func?
        
        let perp = try! Vector3D.crossProduct(lhs: axisDir, rhs: self)
        
        let alongStep = self * cos(angleRad)
        let perpStep = perp * sin(angleRad)
        
        var rotated = alongStep + perpStep
        rotated.normalize()
        
        return rotated
    }
    
    
    /// Construct a vector re-directed one quarter turn away in the counterclockwise direction in the XY plane
    /// Use crossProduct to do this for a more general case
    public func perp() -> Vector3D   {
        
        let rightAngle = Vector3D(i: -self.j, j: self.i, k: 0.0)   // Perpendicular in a CCW direction
        
        return rightAngle
    }
    
    
    /// Construct vector from first input point towards the second
    /// Does not check for a zero vector
    /// - Parameters:
    ///   - from: Start point
    ///   - towards: End point
    ///   - unit: Whether or not the result should be a unit vector
    /// - See: 'testBuiltFrom' under Vector3DTests
    public static func built(from: Point3D, towards: Point3D, unit: Bool = false) -> Vector3D {
        
        var deltaX = towards.x - from.x
        var deltaY = towards.y - from.y
        var deltaZ = towards.z - from.z
        
        if unit   {
            
            let len = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
            
            if len != Vector3D.EpsilonV   {
                deltaX = deltaX / len
                deltaY = deltaY / len
                deltaZ = deltaZ / len
            }
        }
        
        return Vector3D(i: deltaX, j: deltaY, k: deltaZ)
    }
    
    /// Standard definition of dot product
    /// - See: 'testDot' under Vector3DTests
    public static func dotProduct(lhs: Vector3D, rhs: Vector3D) -> Double   {
        
        return lhs.i * rhs.i + lhs.j * rhs.j + lhs.k * rhs.k
    }
    
    /// Standard definition of cross product
    /// This makes no assumptions or guarantees about normalized vectors
    /// - Throws: IdenticalVectorError if the inputs are identical or opposite
    /// - Throws: IdenticalVectorError if the inputs are scaled versions of each other
    /// - See: 'testCross' under Vector3DTests
    public static func crossProduct(lhs: Vector3D, rhs: Vector3D) throws -> Vector3D   {
        
        guard(lhs != rhs) else { throw IdenticalVectorError(dir: lhs)}
        guard(!Vector3D.isOpposite(lhs: lhs, rhs: rhs)) else { throw IdenticalVectorError(dir: lhs)}
        
        // TODO: Add a more appropriate error type
        let flag1 = try Vector3D.isScaled(lhs: lhs, rhs: rhs)
        guard(!flag1) else {throw IdenticalVectorError(dir: lhs)}
        
        
        let freshI = lhs.j * rhs.k - lhs.k * rhs.j
        let freshJ = lhs.k * rhs.i - lhs.i * rhs.k   // Notice the different ordering
        let freshK = lhs.i * rhs.j - lhs.j * rhs.i
        
        
        return Vector3D(i: freshI, j: freshJ, k: freshK)
    }
    
    /// Check for vectors with the same direction but a different sense
    /// This assumes that they are of identical length
    /// - SeeAlso:  isScaled()
    /// - See: 'testIsOpposite' under Vector3DTests
    public static func isOpposite(lhs: Vector3D, rhs: Vector3D) -> Bool   {
        
        let tempVec = lhs * -1.0
        return rhs == tempVec
    }
    
    /// Check to see if one vector is a scaled version of the other
    /// Could be used before doing cross product
    /// - Throws: ZeroVectorError if either input is of zero length
    /// - SeeAlso:  isOpposite()
    public static func isScaled(lhs: Vector3D, rhs: Vector3D) throws -> Bool  {
        
        guard(!lhs.isZero()) else {  throw ZeroVectorError(dir: lhs)  }
        guard(!rhs.isZero()) else {  throw ZeroVectorError(dir: rhs)  }
        
        var leftNormalized = Vector3D(i: lhs.i, j: lhs.j, k: lhs.k)
        leftNormalized.normalize()
        
        var rightNormalized = Vector3D(i: rhs.i, j: rhs.j, k: rhs.k)
        rightNormalized.normalize()
        
        let flag1 = leftNormalized == rightNormalized
        let flag2 = Vector3D.isOpposite(lhs: leftNormalized, rhs: rightNormalized)
        
        return flag1 || flag2
    }
    
    
    /// Find a positive or negative angle between two unit vectors
    /// - Parameters:
    ///   - baselineVec: Unit direction vector to be measured from
    ///   - measureTo: Unit direction vector of interest
    ///   - perp: Unit normal vector used to determine positive and negative
    /// - Throws: NonUnitDirectionError
    /// - Returns: Angle in radians between -M_PI and M_PI
    /// - See: 'testFindAngle' under Vector3DTests
    public static func findAngle(baselineVec: Vector3D, measureTo: Vector3D, perp: Vector3D) throws -> Double   {
        
        guard baselineVec.isUnit()  else  { throw NonUnitDirectionError(dir: baselineVec)}
        guard measureTo.isUnit()  else  { throw NonUnitDirectionError(dir: measureTo)}
        guard perp.isUnit()  else  { throw NonUnitDirectionError(dir: perp)}
        
        
        let projection = Vector3D.dotProduct(lhs: baselineVec, rhs: measureTo)
        var angle = acos(projection)   // Default case.  May be negated below
        
           // Should the angle be negated?
        var positiveVert = try! Vector3D.crossProduct(lhs: perp, rhs: baselineVec)
        positiveVert.normalize()
        
        let side = Vector3D.dotProduct(lhs: measureTo, rhs: positiveVert)        
        if side < 0.0   { angle = -1.0 * angle }
        
        return angle
    }
    
    
    
    /// Build a Vector3D in the XY plane
    /// - Parameter: angle: Desired angle in degrees
    public static func makeXZ(angle: Double) -> Vector3D  {
        
        let angleRad = angle * (Double.pi / 180.0)
        let myI = sin(angleRad)
        let myK = cos(angleRad)
        
        var direction = Vector3D(i: myI, j: 0.0, k: myK)
        direction.normalize()
        
        return direction
    }
    
    /// Compare each component of the vector for equality
    /// - See: 'testEquals' under Vector3DTests
    public static func == (lhs: Vector3D, rhs: Vector3D) -> Bool   {
        
        let flagI = abs(rhs.i - lhs.i) < Vector3D.EpsilonV
        let flagJ = abs(rhs.j - lhs.j) < Vector3D.EpsilonV
        let flagK = abs(rhs.k - lhs.k) < Vector3D.EpsilonV
        
        return flagI && flagJ && flagK
    }
    
}    // End of struct Vector3D definition


/// Construct a vector that is the sum of the two input vectors
/// - See: 'testPlus' under Vector3DTests
public func + (lhs: Vector3D, rhs: Vector3D) -> Vector3D   {
    
    return Vector3D(i: lhs.i + rhs.i, j: lhs.j + rhs.j, k: lhs.k + rhs.k)
}

/// Construct a vector that is the difference between the two input vectors
/// - See: 'testMinus' under Vector3DTests
public func - (lhs: Vector3D, rhs: Vector3D) -> Vector3D   {
    
    return Vector3D(i: lhs.i - rhs.i, j: lhs.j - rhs.j, k: lhs.k - rhs.k)
}

/// Construct a vector by scaling the Vector3D by the Double argument
/// - SeeAlso:  crossProduct()
/// - SeeAlso:  dotProduct()
/// - See: 'testScaling' under Vector3DTests
public func * (lhs: Vector3D, scalar: Double) -> Vector3D   {
    
    let scaledI = lhs.i * scalar
    let scaledJ = lhs.j * scalar
    let scaledK = lhs.k * scalar
    
    return Vector3D(i: scaledI, j: scaledJ, k: scaledK)
}
