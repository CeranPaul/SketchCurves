//
//  Vector3DTests.swift
//  SketchCurves
//
//  Created by Paul on 10/30/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class Vector3DTests: XCTestCase {

    // Verify the original value for Epsilon
    func testEpsilonV()   {
        
        let target = 0.0001
        XCTAssert(target == Vector3D.EpsilonV)
    }
    
    
    // Verify that the length member function produces the expected results
    func testLength() {
        
        var trial = Vector3D(i: 3.0, j: 0.0, k: 4.0)
        XCTAssert(trial.length() == 5.0)
        
        trial = Vector3D(i: 0.0, j: 5.0, k: 12.0)
        XCTAssert(trial.length() == 13.0)
        
        trial = Vector3D(i: 12.0, j: 4.0, k: 3.0)
        XCTAssert(trial.length() == 13.0)
        
    }
    
    // Confirm that the unit check works
    func testIsUnit()   {
        
        var trial = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        XCTAssert(trial.isUnit())
        
        trial = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        XCTAssert(trial.isUnit())
        
        trial = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        XCTAssert(trial.isUnit())
        
        trial = Vector3D(i: 0.6, j: 0.0, k: 0.8)
        XCTAssert(trial.isUnit())
        
        trial = Vector3D(i: 1.0, j: 1.0, k: 2.0)
        XCTAssertFalse(trial.isUnit())
        
        trial = Vector3D(i: -3.0, j: -4.0, k: -12.0)
        trial.normalize()   // Safe by inspection
        
        XCTAssert(trial.isUnit())
    }
    
    // Confirm that a zero vector is recognized
    func testIsZero()   {
        
        var trial = Vector3D(i: 0.1, j: 0.25, k: 0.003)
        XCTAssertFalse(trial.isZero())
        
        trial = Vector3D(i: 0.0, j: 0.0, k: 0.003)
        XCTAssertFalse(trial.isZero())
        
        trial = Vector3D(i: 0.0, j: 0.0, k: 0.0)
        XCTAssert(trial.isZero())
        
        trial = Vector3D(i: -3.0, j: -4.0, k: -12.0)
        XCTAssertFalse(trial.isZero())
    }
    
    // Be certain that the func for normalizing does its job
    func testNormalize()   {
        
        var trial = Vector3D(i: 0.1, j: 0.25, k: 0.003)
        XCTAssertFalse(trial.length() == 1.0)
        
        trial.normalize()   // Safe by inspection
        XCTAssertEqual (trial.length(), 1.0, accuracy: Vector3D.EpsilonV / 3.0)

    }
    
    
    // Check the overloaded equality function
    func testEquals()   {
        
        let ping = Vector3D(i: 1.0, j: 2.0, k: 3.0)
        let pong = Vector3D(i: 1.0, j: 2.0, k: 3.0)
        
        XCTAssert(ping == pong)
        
        var pong2 = Vector3D(i: 1.0, j: 2.0, k: 5.0)
        XCTAssertFalse(ping == pong2)
        
        pong2 = Vector3D(i: 4.0, j: 2.0, k: 3.0)
        XCTAssertFalse(ping == pong2)
        
        pong2 = Vector3D(i: 1.0, j: 6.5, k: 3.0)
        XCTAssertFalse(ping == pong2)

        pong2 = Vector3D(i: -1.0, j: -2.0, k: -3.0)
        XCTAssertFalse(ping == pong2)
    }
    
    // Test a common construction operation
    /// Needs to have a test for the optional parameter
    func testBuiltFrom()   {
        
        let alpha = Point3D(x: 1.5, y: 2.0, z: -1.7)
        let beta = Point3D(x: 15.0, y: 0.15, z: 3.0)
        
        let target = Vector3D(i: 13.5, j: -1.85, k: 4.7)
        
        let trial = Vector3D.built(from: alpha, towards: beta)
        
        XCTAssert(trial == target)
        
    }
    
    // Check the scaling operation
    func testScaling()   {
        
        let raw = Vector3D(i: 1.0, j: 2.0, k: 3.0)
        
        let desired = Vector3D(i: 4.5, j: 9.0, k: 13.5)
        
        let scaled = raw * 4.5
        
        XCTAssert(scaled == desired)
        
        
        let negShrink = Vector3D(i: -0.2, j: -0.4, k: -0.6)
        
        let scaled2 = raw * -0.2
        
        XCTAssert(scaled2 == negShrink)
        
        let nilVec = Vector3D(i: 0.0, j: 0.0, k: 0.0)
        
        let scaled3 = raw * 0.0
        
        XCTAssert(scaled3 == nilVec)
        
        
    }
    
    // Check for difference between direction and sense
    func testIsOpposite()   {
        
        let slope = Vector3D(i: 0.0, j: 0.866, k: 0.5)
        let downhill = Vector3D(i: 0.0, j: -0.866, k: -0.5)
        
        XCTAssert(Vector3D.isOpposite(lhs: slope, rhs: downhill))
        
        let coast = Vector3D(i: 0.0, j: -0.866, k: 0.5)
        XCTAssertFalse(Vector3D.isOpposite(lhs: slope, rhs: coast))
        
    }
    
    
    // Check 'reverse' function
    func testReverse()   {
        
        let target = Vector3D(i: 3.0, j: -7.0, k: 2.1)
        
        let forward = Vector3D(i: -3.0, j: 7.0, k: -2.1)
        
        let backwards = forward.reverse()
        
        XCTAssert(backwards == target)
    }
    
    // TODO:  Add more useful assertions
    func testTransform()  {
        
        let sqrt22 = sqrt(2.0) / 2.0
        let target = Vector3D(i: 0.866 * sqrt22, j: 0.866 * sqrt22, k: 0.5)
        
        let orig = Vector3D(i: 0.866, j: 0.0, k: 0.5)
        
        let t = Transform(rotationAxis: Axis.z, angleRad: Double.pi / 4.0)
        
        let swung = orig.transform(xirtam: t)
        
        XCTAssertEqual(swung, target)
    }
    
    // TODO: Add more complete tests for cross product
    func testCross()   {
        
        let zee = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let horiz = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let vert = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        var trial = try! Vector3D.crossProduct(lhs: horiz, rhs: vert)
        
        XCTAssert(trial == zee)
        
        trial = try! Vector3D.crossProduct(lhs: vert, rhs: zee)
        XCTAssert(trial == horiz)
        
        trial = try! Vector3D.crossProduct(lhs: zee, rhs: horiz)
        XCTAssert(trial == vert)
        
        
        
        let there = Vector3D(i: 0.4, j: -0.3, k: 0.9)
        let thereDupe = Vector3D(i: 0.4, j: -0.3, k: 0.9)
        
        XCTAssertThrowsError(try Vector3D.crossProduct(lhs: there, rhs: thereDupe))
        
        let thereNeg = Vector3D(i: -0.4, j: 0.3, k: -0.9)
        XCTAssertThrowsError(try Vector3D.crossProduct(lhs: thereNeg, rhs: there))
        
        let thereScale = Vector3D(i: 0.8, j: -0.6, k: 1.8)
        XCTAssertThrowsError(try Vector3D.crossProduct(lhs: there, rhs: thereScale))
        
        let thereScaleNeg = Vector3D(i: -0.8, j: 0.6, k: -1.8)
        XCTAssertThrowsError(try Vector3D.crossProduct(lhs: there, rhs: thereScaleNeg))

           // See that non-scaled vectors don't throw
        let there1 = Vector3D(i: 0.4, j: -0.3, k: 0.9)
        let there2 = Vector3D(i: 0.4, j: 0.3, k: -0.9)
        
        XCTAssertNoThrow(try Vector3D.crossProduct(lhs: there1, rhs: there2))
            
        
        /// Handy numbers for building vectors
        let sqrt22 = sqrt(2.0) / 2.0
        let sqrt32 = sqrt(3.0) / 2.0
        
        var base = Vector3D(i: 2.5 * sqrt22, j: 2.5 * sqrt22, k: 0.0)
        base.normalize()
        
        var closer = Vector3D(i: -2.5 * sqrt32, j: -2.5 * 0.5, k: 0.0)
        closer.normalize()
        
        var farther = Vector3D(i: -2.5 * 0.5, j: -2.5 * sqrt32, k: 0.0)
        farther.normalize()
        
        var incoming = try! Vector3D.crossProduct(lhs: base, rhs: closer)
        incoming.normalize()
        print(incoming)
        XCTAssertEqual(incoming.k, 1.0, accuracy: 0.0001)
        
        var outgoing = try! Vector3D.crossProduct(lhs: base, rhs: farther)
        outgoing.normalize()
        print(outgoing)
        
        XCTAssertEqual(outgoing.k, -1.0, accuracy: 0.0001)
        
    }
    
    
    // TODO: Add more complete tests for dot product
    func testDot()  {
        let there = Vector3D(i: 0.3, j: 0.4, k: 0.9)
        let there2 = Vector3D(i: 0.3, j: 0.4, k: 0.9)
        
        let trial = Vector3D.dotProduct(lhs: there, rhs: there2)
        
        XCTAssert(trial == 1.06)
    }
    
    func testFindAngle()   {
        
        /// Reference vector for "up"
        let rocket = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let thisWay = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let thatWay = Vector3D(i: 0.0, j: -1.0, k: 0.0)
        
        let target = -Double.pi / 2.0
        
        XCTAssertNoThrow(try Vector3D.findAngle(baselineVec: thisWay, measureTo: thatWay, perp: rocket))
        let trial = try! Vector3D.findAngle(baselineVec: thisWay, measureTo: thatWay, perp: rocket)
        
        XCTAssertEqual(trial, target, accuracy: Vector3D.EpsilonV)


        let thatWay2 = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        let trial2 = try! Vector3D.findAngle(baselineVec: thisWay, measureTo: thatWay2, perp: rocket)
        let target2 = -Double.pi / 6.0
        
        XCTAssertEqual(trial2, target2, accuracy: Vector3D.EpsilonV)

        
        let thatWay3 = Vector3D(i: -1.0, j: 0.0, k: 0.0)
        let trial3 = try! Vector3D.findAngle(baselineVec: thisWay, measureTo: thatWay3, perp: rocket)
        let target3 = Double.pi
        
        XCTAssertEqual(trial3, target3, accuracy: Vector3D.EpsilonV)
        
        
        let thatWay4 = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let trial4 = try! Vector3D.findAngle(baselineVec: thisWay, measureTo: thatWay4, perp: rocket)
        let target4 = 0.0
        
        XCTAssertEqual(trial4, target4, accuracy: Vector3D.EpsilonV)
        
           // Test the guard statements
        let heinous = Vector3D(i: 0.0, j: 0.0, k: 0.0)
        
        XCTAssertThrowsError(try Vector3D.findAngle(baselineVec: heinous, measureTo: thatWay4, perp: rocket))
        XCTAssertThrowsError(try Vector3D.findAngle(baselineVec: thisWay, measureTo: heinous, perp: rocket))
        XCTAssertThrowsError(try Vector3D.findAngle(baselineVec: thisWay, measureTo: thatWay4, perp: heinous))
    }
    
    // Test addition
    func testPlus()   {
        
        let there = Vector3D(i: 0.3, j: 0.4, k: 0.9)
        let there2 = Vector3D(i: 0.4, j: 0.3, k: -0.9)
        
        let target = Vector3D(i: 0.7, j: 0.7, k: 0.0)
        
        let trial = there + there2
        
        XCTAssert(trial == target)
    }
    
    
    // Test subtraction
    func testMinus()   {
        
        let there = Vector3D(i: 1.3, j: 0.4, k: 0.9)
        let there2 = Vector3D(i: 0.4, j: -0.3, k: -0.9)
        
        let target = Vector3D(i: -0.9, j: -0.7, k: -1.8)
        
        let trial = there2 - there
        
        XCTAssert(trial == target)
    }
    
    func testIsScaled()   {
        
        let pristine = Vector3D(i: 1.0, j: 2.0, k: 3.0)
        
        let bigger = Vector3D(i: 4.5, j: 9.0, k: 13.5)
        
        let smaller = Vector3D(i: 0.4, j: 0.8, k: 1.2)
        
        XCTAssert(try! Vector3D.isScaled(lhs: pristine, rhs: bigger))
        
        XCTAssert(try! Vector3D.isScaled(lhs: pristine, rhs: smaller))

        let heinous = Vector3D(i: 0.0, j: 0.0, k: 0.0)
        
        XCTAssertThrowsError(try Vector3D.isScaled(lhs: pristine, rhs: heinous))
        
        XCTAssertThrowsError(try Vector3D.isScaled(lhs: heinous, rhs: pristine))

   }
    
}
