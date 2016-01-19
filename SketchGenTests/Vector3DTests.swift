//
//  Vector3DTests.swift
//  SketchCurves
//
//  Created by Paul on 10/30/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class Vector3DTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // Verify the fidelity of recording the inputs
    func testFidelity()  {
        
        var trial = Vector3D(i: 3.0, j: 10.0, k: 12.0)
        XCTAssert(trial.i == 3.0)
        XCTAssert(trial.j == 10.0)
        XCTAssert(trial.k == 12.0)
        
        trial = Vector3D(i: -1.0, j: -5.0, k: -2.5)
        XCTAssert(trial.i == -1.0)
        XCTAssert(trial.j == -5.0)
        XCTAssert(trial.k == -2.5)
        
    }
    
    // Verify the original value for Epsilon
    func testEpsilonV()   {
        
        let target = 0.001
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
        trial.normalize()
        
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
        
        trial.normalize()
        XCTAssertEqualWithAccuracy (trial.length(), 1.0, accuracy: Vector3D.EpsilonV / 3.0, "");   // I have no idea what the string does
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
        
        XCTAssert(Vector3D.isOpposite(slope, rhs: downhill))
        
        let coast = Vector3D(i: 0.0, j: -0.866, k: 0.5)
        XCTAssertFalse(Vector3D.isOpposite(slope, rhs: coast))
        
    }
    
    
    // Check 'reverse' function
    func testReverse()   {
        
        let target = Vector3D(i: 3.0, j: -7.0, k: 2.1)
        
        let forward = Vector3D(i: -3.0, j: 7.0, k: -2.1)
        
        let backwards = forward.reverse()
        
        XCTAssert(backwards == target)
    }
    
    
    // TODO: Add tests for dot product
    // TODO: Add tests for cross product
    // TODO: Add tests for addition
    // TODO: Add tests for subtraction
    
    
}
