//
//  ArcTests.swift
//  SketchCurves
//
//  Created by Paul on 11/12/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class ArcTests: XCTestCase {

    /// Tests the simple parts for one of the inits
    func testFidelity() {

        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        do   {
            let orbit = try Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: false)
            
            XCTAssert(orbit.getCenter() == sun)
            XCTAssert(orbit.getOneEnd() == earth)
            XCTAssert(orbit.getOtherEnd() == atlantis)
            
            XCTAssertFalse(orbit.isFull)
            
        }  catch  {
            print("Screwed up initializing while testing a circle 1")
        }
        
    }

       // Check the ability to figure sweep angle
    func testSweepAngle() {
        
           // Simple case
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        let orbitXY = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: true)
        
        XCTAssert(orbitXY.getSweepAngle() == Double.pi / 2.0)
        
        
        /// Convenient values
        let sqrt22 = sqrt(2.0) / 2.0
        let sqrt32 = sqrt(3.0) / 2.0
        
        
        let earth44 = Point3D(x: 3.5 + 2.0 * sqrt32, y: 6.0 + 2.0 * 0.5, z: 0.0)
        
           // High to high
        let season = try! Arc(center: sun, end1: earth44, end2: atlantis, useSmallAngle: true)
        
        let target = 1.0 * Double.pi / 3.0
        let theta = season.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta, target, accuracy: 0.001)
        
        
           // High to high complement
        let season3 = try! Arc(center: sun, end1: earth44, end2: atlantis, useSmallAngle: false)
        
        let target3 = -1.0 * (2.0 * Double.pi - target)
        let theta3 = season3.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta3, target3, accuracy: 0.001)
        
           // Low to high
        let earth2 = Point3D(x: 3.5 + 2.0 * sqrt32, y: 6.0 - 2.0 * 0.5, z: 0.0)
        
        let season2 = try! Arc(center: sun, end1: earth2, end2: atlantis, useSmallAngle: true)
        
        let target2 = 2.0 * Double.pi / 3.0
        let theta2 = season2.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta2, target2, accuracy: 0.001)
        
           // Low to high complement
        let season4 = try! Arc(center: sun, end1: earth2, end2: atlantis, useSmallAngle: false)
        
        let target4 = -1.0 * (2.0 * Double.pi - target2)
        let theta4 = season4.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta4, target4, accuracy: 0.001)
        
        
           // High to low
        let earth3 = Point3D(x: 3.5 + 2.0 * sqrt32, y: 6.0 + 2.0 * 0.5, z: 0.0)
        
        let atlantis5 = Point3D(x: 3.5 - 2.0 * sqrt22, y: 6.0 - 2.0 * sqrt22, z: 0.0)
        
        let season5 = try! Arc(center: sun, end1: earth3, end2: atlantis5, useSmallAngle: false)
        
        let target5 = -13.0 * Double.pi / 12.0
        let theta5 = season5.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta5, target5, accuracy: 0.001)
        
           // High to low complement
        let season6 = try! Arc(center: sun, end1: earth3, end2: atlantis5, useSmallAngle: true)
        
        let target6 = 11.0 * Double.pi / 12.0
        let theta6 = season6.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta6, target6, accuracy: 0.001)
        
        
           // Low to low
        let season7 = try! Arc(center: sun, end1: earth2, end2: atlantis5, useSmallAngle: false)
        
        let target7 = -17.0 * Double.pi / 12.0
        let theta7 = season7.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta7, target7, accuracy: 0.001)
        
        let season8 = try! Arc(center: sun, end1: earth2, end2: atlantis5, useSmallAngle: true)
        
        // Low to low complement
        let target8 = 7.0 * Double.pi / 12.0
        let theta8 = season8.getSweepAngle()
        
        XCTAssertEqualWithAccuracy(theta8, target8, accuracy: 0.001)
        
    }
    
    /// Also tests YZ plane
    func testFindAxis()   {
        
        let sqrt32 = sqrt(3.0) / 2.0
        
        let c1 = Point3D(x: 0.9, y: -1.21, z: 3.5)
        let s1 = Point3D(x: 0.9, y: -1.21 + sqrt32, z: 3.5 + 0.5)
        let f1 = Point3D(x: 0.9, y: -1.21, z: 3.5 + 1.0)
        
        let slice = try! Arc(center: c1, end1: s1, end2: f1, useSmallAngle: false)
        
        let target = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let trial = slice.getAxisDir()
        
        XCTAssertEqual(trial, target)
    }
    
    
    func testPointAt()   {
        
        let thumb = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let knuckle = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let tip = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        do   {
            let grip = try Arc(center: thumb, end1: knuckle, end2: tip, useSmallAngle: true)
            
            var spot = try! grip.pointAt(t: 0.5)
            
            XCTAssert(spot.z == 0.0)
            XCTAssert(spot.y == 6.0 + 2.squareRoot())
            XCTAssert(spot.x == 3.5 + 2.squareRoot())
            
            spot = try! grip.pointAt(t: 0.0)
            
            XCTAssert(spot.z == 0.0)
            XCTAssert(spot.y == 6.0)
            XCTAssert(spot.x == 3.5 + 2.0)
            
        }  catch  {
            print("Screwed up while testing a circle 7")
        }
        
        
           // Another start-at-zero case with a different check method
        let ctr = Point3D(x: 10.5, y: 6.0, z: -1.2)
        
        /// On the horizon
        let green = Point3D(x: 11.8, y: 6.0, z: -1.2)
        
        /// Noon sun
        let checker = Point3D(x: 10.5, y: 7.3, z: -1.2)
        
        let shoulder = try! Arc(center: ctr, end1: green, end2: checker, useSmallAngle: true)
        
        
        var upRight = Vector3D(i: 1.0, j: 1.0, k: 0.0)
        upRight.normalize()
        
        /// Unit slope
        let ray = try! Line(spot: ctr, arrow: upRight)
        
        
        var plop = try! shoulder.pointAt(t: 0.5)
        
        let flag1 = Line.isCoincident(straightA: ray, trial: plop)
        
        XCTAssert(flag1)
        
        
        
           // Clockwise sweep
        let sunSetting = try! Arc(center: ctr, end1: checker, end2: green, useSmallAngle: true)
        
        var clock = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        clock.normalize()
        
        let ray2 = try! Line(spot: ctr, arrow: clock)
        
        plop = try! sunSetting.pointAt(t: 0.666667)
        
        XCTAssert(Line.isCoincident(straightA: ray2, trial: plop))
        
        // TODO: Add tests in a non-XY plane

        
        
        let sunSetting2 = try! Arc(center: ctr, end1: checker, end2: green, useSmallAngle: false)
        
        
        var clock2 = Vector3D(i: 0.0, j: -1.0, k: 0.0)
        clock2.normalize()
        
        var ray3 = try! Line(spot: ctr, arrow: clock2)
        
        plop = try! sunSetting2.pointAt(t: 0.666667)
        XCTAssert(Line.isCoincident(straightA: ray3, trial: plop))
        
        
        let countdown = try! Arc(center: ctr, end1: checker, end2: green, useSmallAngle: false)
        
        clock = Vector3D(i: -1.0, j: 0.0, k: 0.0)
        ray3 = try! Line(spot: ctr, arrow: clock)
        
        plop = try! countdown.pointAt(t: 0.333333)
        XCTAssert(Line.isCoincident(straightA: ray3, trial: plop))
        
    }
    
    func testReverse()   {
        
        let ctr = Point3D(x: 10.5, y: 6.0, z: -1.2)
        
        let green = Point3D(x: 11.8, y: 6.0, z: -1.2)
        let checker = Point3D(x: 10.5, y: 7.3, z: -1.2)
        
        /// One quarter of a full circle - in quadrant I
        let shoulder = try! Arc(center: ctr, end1: green, end2: checker, useSmallAngle: true)
        
        XCTAssertEqual(Double.pi / 2.0, shoulder.getSweepAngle())
        
        var clock1 = Vector3D(i: 0.5, j: 0.866, k: 0.0)
        clock1.normalize()
        
        let ray1 = try! Line(spot: ctr, arrow: clock1)
        
        var plop = try! shoulder.pointAt(t: 0.666667)
        
        XCTAssert(Line.isCoincident(straightA: ray1, trial: plop))
        
        
        shoulder.reverse()
        
        var clock2 = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        clock2.normalize()
        
        let ray2 = try! Line(spot: ctr, arrow: clock2)
        
        plop = try! shoulder.pointAt(t: 0.666667)
        
        XCTAssert(Line.isCoincident(straightA: ray2, trial: plop))
    }
    
    func testEquals() {
        
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        let betelgeuse = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let planetX = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let planetY = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        let solarSystem1 = try! Arc(center: sun, end1: earth, end2: atlantis, useSmallAngle: false)
        
        let solarSystem2 = try! Arc(center: betelgeuse, end1: planetX, end2: planetY, useSmallAngle: false)
        
        XCTAssert(solarSystem1 == solarSystem2)
        
    }
    
    /// Look for CoincidentPointErrors
    func testErrorThrow()  {
        
        let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
//        let e1 = Point3D(x: 3.0, y: 1.0, z: 5.0)
        let e2 = Point3D(x: 2.0, y: 2.0, z: 5.0)
        
           // Bad referencing should cause an error to be thrown
        XCTAssertThrowsError(try Arc(center: ctr, end1: e2, end2: ctr, useSmallAngle: false))

        
        let sun = Point3D(x: 3.5, y: 6.0, z: 0.0)
        let earth = Point3D(x: 5.5, y: 6.0, z: 0.0)
        let atlantis = Point3D(x: 3.5, y: 8.0, z: 0.0)
        
        do   {
            let orbit = try Arc(center: sun, end1: earth, end2: earth, useSmallAngle: false)
            
            XCTAssert(orbit.isFull)   // Presumably never gets to this test
            
        }  catch is CoincidentPointsError  {
            XCTAssert(true)
        }  catch  {
            print("Screwed up while testing a circle 2")
        }
        
        XCTAssertThrowsError(try Arc(center: sun, end1: sun, end2: atlantis, useSmallAngle: false))
    }
    
    
    func testSimpleExtent()   {
        
        let axis = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
        let e1 = Point3D(x: 4.5, y: 1.0, z: 5.0)
        
        var theta = Double.pi / 4.0 + 0.15
        var shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        
        var brick = shield.simpleExtent()
        
        XCTAssertEqual(brick.getOrigin().x, shield.rad * cos(theta))
        XCTAssertEqual(brick.getOrigin().y, 0.0)
        XCTAssertEqual(brick.getOrigin().z, -shield.rad / 10.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), shield.rad * (1.0 - cos(theta)), accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), shield.rad * sin(theta), accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqual(brick.getDepth(), shield.rad / 5.0)
        
        
           // Push the angle into quadrant II
        theta = Double.pi / 2.0 + 0.15
        
        shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        brick = shield.simpleExtent()
        
        XCTAssertEqualWithAccuracy(brick.getOrigin().x, shield.rad * cos(theta), accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), shield.rad * (1.0 - cos(theta)), accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
           // Push the angle into quadrant III
        theta = Double.pi + 0.15
        
        shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        brick = shield.simpleExtent()
        
        XCTAssertEqualWithAccuracy(brick.getOrigin().x, -shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), 2.0 * shield.rad, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), shield.rad - shield.rad * sin(theta), accuracy: Point3D.Epsilon / 3.0)
        
           // Push the angle into quadrant IV
        theta = Double.pi * 3.0 / 2.0 + 0.15
        
        shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        brick = shield.simpleExtent()
        
        XCTAssertEqualWithAccuracy(brick.getOrigin().x, -shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), 2.0 * shield.rad, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), 2.0 * shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
           // Negative angle - quadrant IV
        theta = -Double.pi / 2.0 + 0.15
        
        shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        brick = shield.simpleExtent()
        
        XCTAssertEqualWithAccuracy(brick.getOrigin().x, shield.rad * cos(theta), accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getOrigin().y, shield.rad * sin(theta), accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), shield.rad * (1.0 - cos(theta)), accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), -1.0 * shield.rad * sin(theta), accuracy: Point3D.Epsilon / 3.0)
        
           // Negative angle - quadrant III
        theta = -Double.pi + 0.15
        
        shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        brick = shield.simpleExtent()
        
        XCTAssertEqualWithAccuracy(brick.getOrigin().x, shield.rad * cos(theta), accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getOrigin().y, -shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), shield.rad * (1.0 - cos(theta)), accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
           // Negative angle - quadrant II
        theta = -Double.pi * 3.0 / 2.0 + 0.15
        
        shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        brick = shield.simpleExtent()
        
        XCTAssertEqualWithAccuracy(brick.getOrigin().x, -shield.rad, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getOrigin().y, -shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), 2.0 * shield.rad, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), shield.rad * (1.0 + sin(theta)), accuracy: Point3D.Epsilon / 3.0)
        
           // Negative angle - quadrant I
        theta = -Double.pi * 2.0 + 0.15
        
        shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: theta)
        brick = shield.simpleExtent()
        
        XCTAssertEqualWithAccuracy(brick.getOrigin().x, -shield.rad, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getOrigin().y, -shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(brick.getWidth(), 2.0 * shield.rad, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(brick.getHeight(), 2.0 * shield.rad, accuracy: Point3D.Epsilon / 3.0)
        
   }
    
    
    func testExtent()   {
        
        let axis = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let ctr = Point3D(x: 2.0, y: 1.0, z: 5.0)
        let e1 = Point3D(x: 4.5, y: 1.0, z: 5.0)
        
        let shield = try! Arc(center: ctr, axis: axis, end1: e1, sweep: Double.pi)
        
        let box = shield.getExtent()
        
        XCTAssertEqualWithAccuracy(box.getOrigin().x, -0.5, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(box.getOrigin().y, 1.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(box.getOrigin().z, 5.0 - shield.rad / 10.0, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(box.getWidth(), 5.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(box.getHeight(), 2.5, accuracy: Point3D.Epsilon / 3.0)
        
        let sqrt22 = sqrt(2.0) / 2.0

           // Spin around Z-axis
        let e2 = Point3D(x: 2.0 + 3.0 * sqrt22, y: 1.0 + 3.0 * sqrt22, z: 5.0)
        let shield3 = try! Arc(center: ctr, axis: axis, end1: e2, sweep: Double.pi)
        let box3 = shield3.getExtent()
        
        XCTAssertEqualWithAccuracy(box3.getOrigin().x, -0.5, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(box3.getOrigin().y, 1.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(box3.getOrigin().z, 5.0 - shield.rad / 10.0, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(box3.getWidth(), 5.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(box3.getHeight(), 2.5, accuracy: Point3D.Epsilon / 3.0)
        
        
        
           // Tilt around the X-axis
        var axis2 = Vector3D(i: 0.0, j: 0.707, k: 0.707)
        axis2.normalize()
        
        let shield2 = try! Arc(center: ctr, axis: axis2, end1: e1, sweep: Double.pi)
        let box2 = shield2.getExtent()
        
        XCTAssertEqualWithAccuracy(box2.getOrigin().x, -0.5, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(box2.getWidth(), 5.0, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(box2.getHeight(), shield2.rad * (1.0 + 0.2) * sqrt22, accuracy: Point3D.Epsilon / 3.0)
        
        
        
        
    }
    
}
