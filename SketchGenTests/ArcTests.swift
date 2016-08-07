//
//  ArcTests.swift
//  BoxChopDemo
//
//  Created by Paul on 11/12/15.
//  Copyright © 2015 Paul Hollingshead. All rights reserved.  See LICENSE.md
//

import XCTest

class ArcTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFidelity() {

        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        do   {
            let orbit = try Arc(center: sun, end1: earth, end2: atlantis, isCW: false)
            
            XCTAssert(orbit.getCenter() == sun)
            XCTAssert(orbit.getOneEnd() == earth)
            XCTAssert(orbit.getOtherEnd() == atlantis)
            
        }  catch  {
            print("Screwed up while testing a circle 1")
        }
        
        do   {
            let orbit = try Arc(center: sun, end1: earth, end2: atlantis, isCW: false)
            
            XCTAssertFalse(orbit.isFull)
            
        }  catch  {
            print("Screwed up while testing a circle 2")
        }
        
        do   {
            let orbit = try Arc(center: sun, end1: earth, end2: earth, isCW: false)
            
            XCTAssert(orbit.isFull)
            
        }  catch  {
            print("Screwed up while testing a circle 4")
        }
        
        do   {
            let orbit = try Arc(center: sun, end1: earth, end2: atlantis, isCW: false)
            
            XCTAssertFalse(orbit.isClockwise)
            
        }  catch  {
            print("Screwed up while testing a circle 5")
        }
        
    }

    func testRange() {
        
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        let orbitXY = try! Arc(center: sun, end1: earth, end2: atlantis, isCW: false)
        
        XCTAssert(orbitXY.range == M_PI_2)
        
        
    }
    
    func testFindAxis()   {
        
        let sqrt32 = sqrt(3.0) / 2.0
        
        let c1 = Point3D(x: 0.9, y: -1.21, z: 3.5)
        let s1 = Point3D(x: 0.9, y: -1.21 + sqrt32, z: 3.5 + 0.5)
        let f1 = Point3D(x: 0.9, y: -1.21, z: 3.5 + 1.0)
        
        let slice = try! Arc(center: c1, end1: s1, end2: f1, isCW: false)
        
        var target = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let trial = slice.findAxis()
        
        XCTAssertEqual(trial, target)
    }
    
    /// Only tests in the XY plane
    func testPointAtAngle()   {
        
        let ctr = Point3D(x: -10.5, y: 3.0, z: -1.2)
        
        let green = Point3D(x: -9.2, y: 3.0, z: -1.2)
        let checker = Point3D(x: -10.5, y: 4.3, z: -1.2)
        
        let shoulder = try! Arc(center: ctr, end1: green, end2: checker, isCW: true)
        
        var clock = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        try! clock.normalize()
        
        let ray = try! Line(spot: ctr, arrow: clock)
        
        var splat = shoulder.pointAtAngle(M_PI / 6.0)
        
        XCTAssert(Line.isCoincident(ray, trial: splat))
    }
    
    func testPointAtT()   {
        
        let thumb = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let knuckle = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let tip = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        do   {
            let grip = try Arc(center: thumb, end1: knuckle, end2: tip, isCW: false)
            
            var spot = grip.pointAt(0.5)
            
            XCTAssert(spot.z == 0.0)
            XCTAssert(spot.y == 6.0 + M_SQRT2)
            XCTAssert(spot.x == 3.5 + M_SQRT2)
            
            spot = grip.pointAt(0.0)
            
            XCTAssert(spot.z == 0.0)
            XCTAssert(spot.y == 6.0)
            XCTAssert(spot.x == 3.5 + 2.0)
            
        }  catch  {
            print("Screwed up while testing a circle 7")
        }
        
        
        
        let ctr = Point3D(x: 10.5, y: 6.0, z: -1.2)
        
        /// On the horizon
        let green = Point3D(x: 11.8, y: 6.0, z: -1.2)
        
        /// Noon sun
        let checker = Point3D(x: 10.5, y: 7.3, z: -1.2)
        
        let shoulder = try! Arc(center: ctr, end1: green, end2: checker, isCW: true)
        
        
        var upRight = Vector3D(i: 1.0, j: 1.0, k: 0.0)
        try! upRight.normalize()
        
        /// Unit slope
        let ray = try! Line(spot: ctr, arrow: upRight)
        
        
        var plop = shoulder.pointAt(0.5)
        
        let flag1 = Line.isCoincident(ray, trial: plop)
        
        XCTAssert(flag1)
        
    
        let sunSetting = try! Arc(center: ctr, end1: checker, end2: green, isCW: true)
        
        var clock = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        try! clock.normalize()
        
        let ray2 = try! Line(spot: ctr, arrow: clock)
        
        plop = sunSetting.pointAt(0.333333)
        print(plop)
        
        XCTAssert(Line.isCoincident(ray2, trial: plop))
        
        // TODO: Add tests in a non-XY plane
        
    }
    
    func testReverse()   {
        
        let ctr = Point3D(x: 10.5, y: 6.0, z: -1.2)
        
        let green = Point3D(x: 11.8, y: 6.0, z: -1.2)
        let checker = Point3D(x: 10.5, y: 7.3, z: -1.2)
        
        /// One quarter of a full circle - in quadrant I
        let shoulder = try! Arc(center: ctr, end1: green, end2: checker, isCW: false)
        
        XCTAssertEqual(M_PI_2, shoulder.range)
        
        var clock1 = Vector3D(i: 0.5, j: 0.866, k: 0.0)
        try! clock1.normalize()
        
        let ray1 = try! Line(spot: ctr, arrow: clock1)
        
        
        var clock2 = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        try! clock2.normalize()
        
        let ray2 = try! Line(spot: ctr, arrow: clock2)
        
        var plop = shoulder.pointAt(0.333333)
        
        XCTAssert(Line.isCoincident(ray2, trial: plop))
        
        shoulder.reverse()
        
        XCTAssertEqual(shoulder.getOneEnd(), checker)
        XCTAssertEqual(shoulder.getOtherEnd(), green)
        XCTAssertEqual(M_PI_2, shoulder.range)
        
        
        plop = shoulder.pointAt(0.333333)
        
//        XCTAssert(Line.isCoincident(ray1, trial: plop))
        print(shoulder.getOneEnd())
        print(plop)
    }
    
    func testEquals() {
        
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        let betelgeuse = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let planetX = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let planetY = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        do   {
            let solarSystem1 = try Arc(center: sun, end1: earth, end2: atlantis, isCW: false)
            
            let solarSystem2 = try Arc(center: betelgeuse, end1: planetX, end2: planetY, isCW: false)
            
            XCTAssert(solarSystem1 == solarSystem2)
            
        }  catch  {
            print("Screwed up while testing a circle 6")
        }
        
    }
    
    func testErrorThrow()  {
        
        let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
        let e1 = Point3D(x: 3.0, y: 1.0, z: 5.0)
        let e2 = Point3D(x: 2.0, y: 2.0, z: 5.0)
        
           // Bad referencing should cause an error to be thrown
        XCTAssertThrowsError(try Arc(center: ctr, end1: e2, end2: ctr, isCW: true))

        
    }
    
}
