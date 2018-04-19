//
//  TransformPlus.swift
//  SketchGen
//
//  Created by Paul on 2/14/16.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Matrix built the way I was taught in college, as opposed to being twisted to use SIMD.
/// This uses some overloaded operators.
open class Transform   {
    
    var a, b, c, d: Double   // Labeling is done across each row, then down
    var e, f, g, h: Double
    var j, k, m, n: Double
    var p, r, s, t: Double
    
    
    /// Construct an identity matrix.
    /// - See: 'testIdentity' under TransformTests.
    public init()   {
        
        a = 1.0
        b = 0.0
        c = 0.0
        d = 0.0
        
        e = 0.0
        f = 1.0
        g = 0.0
        h = 0.0
        
        j = 0.0
        k = 0.0
        m = 1.0
        n = 0.0
        
        p = 0.0
        r = 0.0
        s = 0.0
        t = 1.0
        
    }

    
    /// Construct a matrix from individual parameters
    public init(a: Double, b: Double, c: Double, d: Double, e: Double, f: Double, g: Double, h: Double, j: Double, k: Double, m: Double, n: Double, p: Double, r: Double, s: Double, t: Double)   {
        
        
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        
        self.e = e
        self.f = f
        self.g = g
        self.h = h
        
        self.j = j
        self.k = k
        self.m = m
        self.n = n
        
        self.p = p
        self.r = r
        self.s = s
        self.t = t
        
 }
    
    
    /// Construct a matrix to do translation only
    /// - See: 'testTranslate' under TransformTests
    public init (deltaX: Double, deltaY: Double, deltaZ: Double)   {
        
        a = 1.0
        b = 0.0
        c = 0.0
        d = 0.0
        
        e = 0.0
        f = 1.0
        g = 0.0
        h = 0.0
        
        j = 0.0
        k = 0.0
        m = 1.0
        n = 0.0
        
        p = deltaX
        r = deltaY
        s = deltaZ
        t = 1.0
    }
    
    /// Construct a matrix to do scaling
    /// scaleY should perhaps be negated for screen display
    /// - See: 'testScale' under TransformTests
    public init (scaleX: Double, scaleY: Double, scaleZ: Double)   {
    
        a = scaleX
        b = 0.0
        c = 0.0
        d = 0.0
        
        e = 0.0
        f = scaleY
        g = 0.0
        h = 0.0
        
        j = 0.0
        k = 0.0
        m = scaleZ
        n = 0.0
        
        p = 0.0
        r = 0.0
        s = 0.0
        t = 1.0
    }

    /// Construct a matrix for rotation around a single axis
    /// - Parameter rotationAxis Center for rotation.  Should be a member of enum Axis
    /// - Parameter angleRad Desired rotation in radians
    /// - Warning:  These each look to be the transpose of how this is normally taught
    /// - See: 'testSimpleRotations' under TransformTests
    public init(rotationAxis: Axis, angleRad: Double)   {
        
        let trigCos = cos(angleRad)
        let trigSin = sin(angleRad)
        
        switch rotationAxis   {
            
        case .x:    a = 1.0
                    b = 0.0
                    c = 0.0
                    d = 0.0
        
                    e = 0.0
                    f = trigCos
                    g = trigSin
                    h = 0.0
        
                    j = 0.0
                    k = -trigSin
                    m = trigCos
                    n = 0.0
        
                    p = 0.0
                    r = 0.0
                    s = 0.0
                    t = 1.0

            
        case .y:    a = trigCos
                    b = 0.0
                    c = -trigSin
                    d = 0.0
        
                    e = 0.0
                    f = 1.0
                    g = 0.0
                    h = 0.0
        
                    j = trigSin
                    k = 0.0
                    m = trigCos
                    n = 0.0
        
                    p = 0.0
                    r = 0.0
                    s = 0.0
                    t = 1.0
            

            
        case .z:    a = trigCos
                    b = trigSin
                    c = 0.0
                    d = 0.0
        
                    e = -trigSin
                    f = trigCos
                    g = 0.0
                    h = 0.0
        
                    j = 0.0
                    k = 0.0
                    m = 1.0
                    n = 0.0
        
                    p = 0.0
                    r = 0.0
                    s = 0.0
                    t = 1.0
        }
    }
    
    /// Create a transform from orthogonal vectors
    /// - Warning:  The vectors are not checked for orthogonality
    /// - Warning:  This makes no attempt to use the local origin
    /// - See: 'testRollYourOwn' under TransformTests
    public init(localX: Vector3D, localY: Vector3D, localZ: Vector3D)   {
        
        self.a = localX.i
        self.b = localX.j
        self.c = localX.k
        self.d = 0.0
        
        self.e = localY.i
        self.f = localY.j
        self.g = localY.k
        self.h = 0.0
        
        self.j = localZ.i
        self.k = localZ.j
        self.m = localZ.k
        self.n = 0.0
        
        self.p = 0.0
        self.r = 0.0
        self.s = 0.0
        self.t = 1.0
                
    }
    
    /// Generate a Transform to rotate and translate from a local CSYS TO the global coordinate system.
    /// Should this become a method of Transform?
    /// - See: 'testGenToGlobal' under CoordinateSystemTests for a partial set of tests
    public static func genToGlobal(csys: CoordinateSystem) -> Transform   {
        
        let rotate = Transform(localX: csys.axisX, localY: csys.axisY, localZ: csys.axisZ)
        let translate = Transform(deltaX: csys.origin.x, deltaY: csys.origin.y, deltaZ: csys.origin.z)
        
        let tform = rotate * translate
        
        return tform
    }
    
    /// Generate a Transform to get points FROM the global CSYS.
    /// Should this become a method of Transform?
    public static func genFromGlobal(csys: CoordinateSystem) -> Transform   {
        
        // Construct the transpose of the 3 x 3
        let newA = csys.axisX.i
        let newB = csys.axisY.i
        let newC = csys.axisZ.i
        let newD = 0.0
        
        let newE = csys.axisX.j
        let newF = csys.axisY.j
        let newG = csys.axisZ.j
        let newH = 0.0
        
        let newJ = csys.axisX.k
        let newK = csys.axisY.k
        let newM = csys.axisZ.k
        let newN = 0.0
        
        let newP = 0.0
        let newR = 0.0
        let newS = 0.0
        let newT = 1.0
        
        let transpose = Transform(a: newA, b: newB, c: newC, d: newD, e: newE, f: newF, g: newG, h: newH, j: newJ, k: newK, m: newM, n: newN, p: newP, r: newR, s: newS, t: newT)
        
        let rowOrig = RowMtx4(ptIn: csys.origin)
        
        
        let flippedOrig = rowOrig * transpose
        
        let invertedTranslate = Transform(deltaX: -1.0 * flippedOrig.a, deltaY: -1.0 * flippedOrig.b, deltaZ: -1.0 * flippedOrig.c)
        
        let tform = transpose * invertedTranslate
        
        return tform
    }
    
    
}   // End of definition for Transform


/// Simple parameter to indicate axis of rotation
public enum Axis {
    
    case x
    
    case y
    
    case z
    
}


/// Row matrix of length 4.
/// Distinct from double4 in simD to control the order of operations.
open class RowMtx4   {
    
    var a, b, c, d:  Double
    
    public init(valOne: Double, valTwo: Double, valThree: Double, valFour: Double)   {
        
        self.a = valOne
        self.b = valTwo
        self.c = valThree
        self.d = valFour
    }
    
    public init(vecIn: Vector3D)   {
        
        self.a = vecIn.i
        self.b = vecIn.j
        self.c = vecIn.k
        self.d = 0.0
    }
    
    
    public init(ptIn: Point3D)   {
        
        self.a = ptIn.x
        self.b = ptIn.y
        self.c = ptIn.z
        self.d = 1.0
    }
    
    /// Create a Point from the result
    open func toPoint() -> Point3D   {
        
        return Point3D(x: a, y: b, z: c)
    }
    
    
    /// Create a Vector from the result
    open func toVector() -> Vector3D   {
        
        return Vector3D(i: a, j: b, k: c)
    }
    
}   // End of definition for RowMtx4


/// Compare two of 'em.
/// - Parameters:
///   - lhs: First transform
///   - rhs: Second transform
///   Returns: Simple flag
public func == (lhs: Transform, rhs: Transform) -> Bool  {
    
    let a = abs(lhs.a - rhs.a) < Vector3D.EpsilonV
    let b = abs(lhs.b - rhs.b) < Vector3D.EpsilonV
    let c = abs(lhs.c - rhs.c) < Vector3D.EpsilonV
    let d = abs(lhs.d - rhs.d) < Vector3D.EpsilonV
    
    let row1 = a && b && c && d
    
    let e = abs(lhs.e - rhs.e) < Vector3D.EpsilonV
    let f = abs(lhs.f - rhs.f) < Vector3D.EpsilonV
    let g = abs(lhs.g - rhs.g) < Vector3D.EpsilonV
    let h = abs(lhs.h - rhs.h) < Vector3D.EpsilonV
    
    let row2 = e && f && g && h
    
    let j = abs(lhs.j - rhs.j) < Vector3D.EpsilonV
    let k = abs(lhs.k - rhs.k) < Vector3D.EpsilonV
    let m = abs(lhs.m - rhs.m) < Vector3D.EpsilonV
    let n = abs(lhs.n - rhs.n) < Vector3D.EpsilonV
    
    let row3 = j && k && m && n
    
    let p = abs(lhs.p - rhs.p) < Point3D.Epsilon
    let r = abs(lhs.r - rhs.r) < Point3D.Epsilon
    let s = abs(lhs.s - rhs.s) < Point3D.Epsilon
    let t = abs(lhs.t - rhs.t) < Point3D.Epsilon
    
    let row4 = p && r && s && t
    
    return row1 && row2 && row3 && row4
}



/// Pre-multiply a row matrix and the square matrix.
/// Used to transform points and vectors
/// Custom code that uses a slightly different order than simd.
/// - Parameters:
///   - pre: Row matrix of length 4
///   - rhs: Transform
/// - See:
public func * (pre: RowMtx4, mtx: Transform) -> RowMtx4   {
    
    /// Result from the first column
    let res1 = pre.a * mtx.a + pre.b * mtx.e + pre.c * mtx.j + pre.d * mtx.p
    
    let res2 = pre.a * mtx.b + pre.b * mtx.f + pre.c * mtx.k + pre.d * mtx.r
    
    let res3 = pre.a * mtx.c + pre.b * mtx.g + pre.c * mtx.m + pre.d * mtx.s
    
    let res4 = pre.a * mtx.d + pre.b * mtx.h + pre.c * mtx.n + pre.d * mtx.t
    
    return RowMtx4.init(valOne: res1, valTwo: res2, valThree: res3, valFour: res4)
}


    //TODO: Add a post multiplication function and its tests

//TODO: Add an identity check?  Can be covered by doing equals with the result of the empty initializer.


/// Combine rotations by multiplying two square matrices.
/// - Parameters:
///   - lhs: First transform
///   - rhs: Second transform
/// - See:
public func * (lhs: Transform, rhs: Transform) -> Transform   {

    /// Using the first row of 'lhs'
    let resA = lhs.a * rhs.a + lhs.b * rhs.e + lhs.c * rhs.j + lhs.d * rhs.p
    
    let resB = lhs.a * rhs.b + lhs.b * rhs.f + lhs.c * rhs.k + lhs.d * rhs.r
    
    let resC = lhs.a * rhs.c + lhs.b * rhs.g + lhs.c * rhs.m + lhs.d * rhs.s
    
    let resD = lhs.a * rhs.d + lhs.b * rhs.h + lhs.c * rhs.n + lhs.d * rhs.t
    
    
    let resE = lhs.e * rhs.a + lhs.f * rhs.e + lhs.g * rhs.j + lhs.h * rhs.p
    
    let resF = lhs.e * rhs.b + lhs.f * rhs.f + lhs.g * rhs.k + lhs.h * rhs.r
    
    let resG = lhs.e * rhs.c + lhs.f * rhs.g + lhs.g * rhs.m + lhs.h * rhs.s
    
    let resH = lhs.e * rhs.d + lhs.f * rhs.h + lhs.g * rhs.n + lhs.h * rhs.t
    
    
    let resJ = lhs.j * rhs.a + lhs.k * rhs.e + lhs.m * rhs.j + lhs.n * rhs.p
    
    let resK = lhs.j * rhs.b + lhs.k * rhs.f + lhs.m * rhs.k + lhs.n * rhs.r
    
    let resM = lhs.j * rhs.c + lhs.k * rhs.g + lhs.m * rhs.m + lhs.n * rhs.s
    
    let resN = lhs.j * rhs.d + lhs.k * rhs.h + lhs.m * rhs.n + lhs.n * rhs.t
    
    
    let resP = lhs.p * rhs.a + lhs.r * rhs.e + lhs.s * rhs.j + lhs.t * rhs.p
    
    let resR = lhs.p * rhs.b + lhs.r * rhs.f + lhs.s * rhs.k + lhs.t * rhs.r
    
    let resS = lhs.p * rhs.c + lhs.r * rhs.g + lhs.s * rhs.m + lhs.t * rhs.s
    
    let resT = lhs.p * rhs.d + lhs.r * rhs.h + lhs.s * rhs.n + lhs.t * rhs.t
    
    
    return Transform(a: resA, b: resB, c: resC, d: resD, e: resE, f: resF, g: resG, h: resH, j: resJ, k: resK, m: resM, n: resN, p: resP, r: resR, s: resS, t: resT)
}



