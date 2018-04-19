//
//  Point3DTests.swift
//  SketchCurves
//
//  Created by Paul on 11/5/15.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class Point3DTests: XCTestCase {

    /// Verify the fidelity of recording the inputs
    func testFidelity()  {
        
        let sample = Point3D(x: 8.0, y: 6.0, z: 4.0)
        
        XCTAssert(sample.x == 8.0)
        XCTAssert(sample.y == 6.0)
        XCTAssert(sample.z == 4.0)
    }

    // Verify the original value for Epsilon
    func testEpsilon()   {
        
        let target = 0.0001
        XCTAssert(target == Point3D.Epsilon)
    }
    
    func testOffset()   {
        
        let local = Point3D(x: -1.0, y: 2.0, z: -3.0)
        
        let jump = Vector3D(i: 1.5, j: 1.5, k: 1.5)
        
        let tip = local.offset(jump: jump)
        
        XCTAssert(tip.x == 0.5)
        XCTAssert(tip.y == 3.5)
        XCTAssert(tip.z == -1.5)
    }
    
    /// Verify the distance function
    func testDist()   {
        
        let here = Point3D(x: -10.0, y: -5.0, z: -23.0)
        let there = Point3D(x: -7.0, y: -9.0, z: -11.0)
        
        let sep = Point3D.dist(pt1: here, pt2: there)
        
        XCTAssert(sep == 13.0)
    }
    
    // Check on calculating a middle point
    func testMidway()   {
        
        let here = Point3D(x: -5.0, y: -10.0, z: -23.0)
        let there = Point3D(x: -9.0, y: -7.0, z: -11.0)
        
        let pbj = Point3D.midway(alpha: here, beta: there)
        
        let target = Point3D(x: -7.0, y: -8.5, z: -17.0)
        
        XCTAssertEqual(pbj, target)
    }
    
    func testIsThreeUnique()   {
        
        let here = Point3D(x: -5.0, y: 5.0, z: 5.0)
        var there = Point3D(x: -9.0, y: 9.0, z: 9.0)
        var pastThere = Point3D(x: -15.0, y: 15.0, z: 15.0)
        
        XCTAssertTrue(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
           // Make the second point be a duplicate of the first
        there = Point3D(x: -5.0, y: 5.0, z: 5.0)
        
        XCTAssertFalse(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
           // Make the third point be a duplicate of the second
        there = Point3D(x: -9.0, y: 9.0, z: 9.0)
        pastThere = Point3D(x: -9.0, y: 9.0, z: 9.0)
        
        XCTAssertFalse(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
           // Make the third point be a duplicate of the first
        pastThere = Point3D(x: -5.0, y: 5.0, z: 5.0)
        
        XCTAssertFalse(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
    }
    
    
    func testIsThreeLinear()   {
        
        let here = Point3D(x: -5.0, y: 5.0, z: 5.0)
        let there = Point3D(x: -9.0, y: 9.0, z: 9.0)
        let pastThere = Point3D(x: -15.0, y: 15.0, z: 15.0)
        
        XCTAssert(Point3D.isThreeUnique(alpha: here, beta: there, gamma: pastThere))
        
        XCTAssert(Point3D.isThreeLinear(alpha: here, beta: there, gamma: pastThere))
        
        
        let missed = Point3D(x: -9.0, y: -9.0, z: 9.0)
        
        XCTAssert(Point3D.isThreeUnique(alpha: here, beta: missed, gamma: pastThere))
        
        XCTAssertFalse(Point3D.isThreeLinear(alpha: here, beta: missed, gamma: pastThere))
    }
    
    func testEqual()   {
        
        let trial = Point3D(x: -3.1, y: 6.8 + 0.75 * Point3D.Epsilon, z: -1.4)
        
        let target = Point3D(x: -3.1, y: 6.8, z: -1.4)
        
        XCTAssert(trial == target)
        
        let trial2 = Point3D(x: -3.1 - 1.5 * Point3D.Epsilon, y: 6.8 + 0.75 * Point3D.Epsilon, z: -1.4)
        
        XCTAssertFalse(trial2 == target)

        
        let trial3 = Point3D(x: -3.7, y: 6.1, z: 10.4)
        
        let target2 = Point3D(x: -3.7, y: 6.1, z: 9.4)
        
        XCTAssert(trial3 != target2)
        
    }
    
    func testMakeCGPoint()   {
        
        let base = Point3D(x: -3.7, y: 6.1, z: 10.4)
        
        let target = CGPoint(x: -3.7, y: 6.1)
        
        let trial = Point3D.makeCGPoint(pip: base)
        
        XCTAssertEqual(trial, target)
        
    }
    
    func testHashValue()   {
        
        let trial = Point3D(x: -3.7, y: 6.1, z: 10.4)
        let trial2 = Point3D(x: -3.7, y: 6.1, z: 10.4)
        let trial3 = Point3D(x: 3.1, y: 6.1, z: 10.4)
        let trial4 = Point3D(x: -3.7, y: 1.6, z: 10.4)
        let trial5 = Point3D(x: -3.7, y: 6.1, z: 1.4)
        
        XCTAssertEqual(trial.hashValue, trial2.hashValue)

        XCTAssertNotEqual(trial.hashValue, trial3.hashValue)
        XCTAssertNotEqual(trial.hashValue, trial4.hashValue)
        XCTAssertNotEqual(trial.hashValue, trial5.hashValue)
    }
    
    func testAngleAbout()   {
        
        let origin = Point3D(x: 5.0, y: 5.0, z: 2.0)
        
        let trial1 = Point3D(x: 3.7, y: 6.3, z: 2.0)
        
        var azim = Point3D.angleAbout(ctr: origin, tniop: trial1)
        
        var target = Double.pi * 3.0 / 4.0
        
        XCTAssertEqual(azim, target)
        
        
        let trial2 = Point3D(x: 6.3, y: 6.3, z: 2.0)
        azim = Point3D.angleAbout(ctr: origin, tniop: trial2)
        target = Double.pi / 4.0
        XCTAssertEqual(azim, target)
        
        let trial3 = Point3D(x: 3.7, y: 3.7, z: 2.0)
        azim = Point3D.angleAbout(ctr: origin, tniop: trial3)
        target = -Double.pi * 3.0 / 4.0
        XCTAssertEqual(azim, target)
        
        let trial4 = Point3D(x: 6.3, y: 3.7, z: 2.0)
        azim = Point3D.angleAbout(ctr: origin, tniop: trial4)
        target = -Double.pi / 4.0
        XCTAssertEqual(azim, target)
        
    }
    
    func testUniquePool()   {
        
        /// Bag o' points
        var pond = [Point3D]()
        
        let ptA = Point3D(x: 5.0, y: 5.0, z: 2.0)
        pond.append(ptA)
        
        let ptB = Point3D(x: 2.0, y: 5.0, z: 5.0)
        pond.append(ptB)
        
        let ptC = Point3D(x: 1.0, y: 4.2, z: 6.0)
        pond.append(ptC)
        
        let ptD = Point3D(x: -3.0, y: 0.95, z: 0.5)
        pond.append(ptD)
        
        
        var light = Point3D.isUniquePool(flock: pond)
        XCTAssert(light)
        
        
        let ptE = Point3D(x: 5.0, y: 5.0, z: 2.0)
        pond.append(ptE)
        
        light = Point3D.isUniquePool(flock: pond)
        XCTAssertFalse(light)
        
    }
    
    // TODO: Add tests for transform, intersectLinePlane, and project
    
}
