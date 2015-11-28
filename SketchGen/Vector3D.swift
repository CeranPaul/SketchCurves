//
//  Vector3D.swift
//  CornerTri
//
//  Created by Paul on 8/11/15.
//

import Foundation

struct Vector3D: Equatable {
    
    var i: Double
    var j: Double
    var k: Double
    
    
    static let EpsilonV: Double = 0.001    // Used as a difference between components in equality checks
    
    
    /// Figure the combined length of all three components
    /// - See: 'testLength' under Vector3DTests
    func length() -> Double {
        
        return sqrt(i * i + j * j + k * k)
    }
    
    /// Check to see if this is a unit vector
    /// - See: 'testIsUnit' under Vector3DTests
    func isUnit() -> Bool   {
        
        return self.length() - 1.0 < Vector3D.EpsilonV
    }
    
    /// Check to see if the vector has zero length
    /// - See: 'testIsZero' under Vector3DTests
    func isZero() -> Bool   {
        
        let flagI = self.i  < Vector3D.EpsilonV
        let flagJ = self.j  < Vector3D.EpsilonV
        let flagK = self.k  < Vector3D.EpsilonV
        
        return flagI && flagJ && flagK
    }
    
    /// Destructively change the vector length to 1.0
    /// - See: 'testNormalize' under Vector3DTests
    mutating func normalize()   {
        
        let denom = self.length()
        
        i = self.i / denom
        j = self.j / denom
        k = self.k / denom
    }
    
    
    /// Construct a vector re-directed one quarter turn away in the counterclockwise direction in the XY plane
    /// - See: Use crossProduct to do this for a more general case
    func perp() -> Vector3D   {
        
        let rightAngle = Vector3D(i: -self.j, j: self.i, k: 0.0)   // Perpendicular in a CCW direction
        
        return rightAngle
    }
    

    /// Construct a vector with the opposite direction
    func reverse() -> Vector3D   {
        
        let ricochet = Vector3D(i: self.i * -1.0, j: self.j * -1.0, k: self.k * -1.0)
        return ricochet
    }
    
    
    /// Construct a vector that has been rotated from self about the axis specified by the first argument
    /// - Parameter  angleRad  The amount that the direction should change  Expressed in radians, not degrees!
    func twistAbout(axisDir: Vector3D, angleRad: Double) -> Vector3D  {   // Should this become a static func?
        
        let perp = Vector3D.crossProduct(axisDir, rhs: self)
        
        let alongStep = self * cos(angleRad)
        let perpStep = perp * sin(angleRad)
        
        var rotated = alongStep + perpStep
        rotated.normalize()
        
        return rotated
    }
    
    
    /// Build a Vector3D in the XY plane
    /// - Parameter: angle: Desired angle in degrees
    static func makeXZ(angle: Double) -> Vector3D  {
        
        let angleRad = angle * (M_PI / 180.0)
        let myI = sin(angleRad)
        let myK = cos(angleRad)
        
        var direction = Vector3D(i: myI, j: 0.0, k: myK)
        direction.normalize()
        
        return direction
    }
    
    /// Construct one from first input point towards the second    See "normalize" above
    static func built(from: Point3D, towards: Point3D) -> Vector3D {
        
        return Vector3D(i: towards.x - from.x, j: towards.y - from.y, k: towards.z - from.z)
    }
    
    /// Check for vectors with the same direction but a different sense
    /// - See: 'testIsOpposite' under Vector3DTests
    static func isOpposite(lhs: Vector3D, rhs: Vector3D) -> Bool   {
        
        let tempVec = lhs * -1.0
        return rhs == tempVec
    }
    
    static func dotProduct(lhs: Vector3D, rhs: Vector3D) -> Double   {
        
        return lhs.i * rhs.i + lhs.j * rhs.j + lhs.k * rhs.k
    }

    static func  crossProduct(lhs: Vector3D, rhs: Vector3D) -> Vector3D   {
        
        let freshI = lhs.j * rhs.k - lhs.k * rhs.j
        let freshJ = lhs.k * rhs.i - lhs.i * rhs.k   // Notice the different ordering
        let freshK = lhs.i * rhs.j - lhs.j * rhs.i

        return Vector3D(i: freshI, j: freshJ, k: freshK)
    }
}

    /// Compare each component of the vector for equality
    /// - See: 'testEquals' under Vector3DTests
    func == (lhs: Vector3D, rhs: Vector3D) -> Bool   {
    
        let flagI = abs(rhs.i - lhs.i) < Vector3D.EpsilonV
        let flagJ = abs(rhs.j - lhs.j) < Vector3D.EpsilonV
        let flagK = abs(rhs.k - lhs.k) < Vector3D.EpsilonV
        
        return flagI && flagJ && flagK
    }

    /// Construct a vector that is the sum of the two input vectors
    func + (lhs: Vector3D, rhs: Vector3D) -> Vector3D   {
    
        return Vector3D(i: lhs.i + rhs.i, j: lhs.j + rhs.j, k: lhs.k + rhs.k)
    }

    /// Construct a vector that is the difference between the two input vectors
    func - (lhs: Vector3D, rhs: Vector3D) -> Vector3D   {
    
        return Vector3D(i: lhs.i - rhs.i, j: lhs.j - rhs.j, k: lhs.k - rhs.k)
    }

    /// Construct a vector by scaling the Vector3D argument by the Double
    func * (lhs: Vector3D, rhs: Double) -> Vector3D   {
    
        let scaledI = lhs.i * rhs
        let scaledJ = lhs.j * rhs
        let scaledK = lhs.k * rhs
    
        return Vector3D(i: scaledI, j: scaledJ, k: scaledK)
    }