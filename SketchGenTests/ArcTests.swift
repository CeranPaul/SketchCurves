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
        
        do   {
            let orbit = try Arc(center: sun, end1: earth, end2: atlantis, isCW: false)
            
            XCTAssert(orbit.range == M_PI_2)
        }  catch  {
            print("Screwed up while testing a circle 3")
        }
        
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
        
        XCTAssertThrowsError(try Arc(center: ctr, end1: e2, end2: ctr, isCW: true))

        
    }
    
}
