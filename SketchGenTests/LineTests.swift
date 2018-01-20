//
//  LineTests.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 12/10/15.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class LineTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /// Verify the fidelity of recording the inputs
    func testFidelity()  {
        
        let nexus = Point3D(x: -2.5, y: 1.5, z: 0.015)
        var horn = Vector3D(i: 12.0, j: 3.0, k: 4.0)
        horn.normalize()
        
        XCTAssertNoThrow( try Line(spot: nexus, arrow: horn) )
        
        let contrail = try! Line(spot: nexus, arrow: horn)   // The previous test verified that this is safe
        
        XCTAssert(contrail.getOrigin().x == -2.5)
        XCTAssert(contrail.getOrigin().y == 1.5)
        XCTAssert(contrail.getOrigin().z == 0.015)
        
        XCTAssert(contrail.getDirection().i == 12.0 / 13.0)
        XCTAssert(contrail.getDirection().j == 3.0 / 13.0)
        XCTAssert(contrail.getDirection().k == 4.0 / 13.0)
        
           // Check that one of the guard statements works
        do {
            
            horn = Vector3D(i: 0.0, j: 0.0, k: 0.0)
            
            _ = try Line(spot: nexus, arrow: horn)
            
        }  catch is ZeroVectorError {
            
            XCTAssert(true)
            
        }  catch  {   // I don't see how you avoid writing this code, and having it be untested
        
            XCTAssert(false)
        }
        
        
            // Check that the other guard statements works
        do {
            
            horn = Vector3D(i: 3.0, j: 2.0, k: 1.0)
            
            _ = try Line(spot: nexus, arrow: horn)
            
        }  catch is NonUnitDirectionError {
            
            XCTAssert(true)
            
        }  catch  {   // I don't see how you avoid writing this code, and having it be untested
            
            XCTAssert(false)
        }
        
    }
    
    func testIsCoincident()   {
        
        let flatOrig = Point3D(x: 1.0, y: 2.0, z: 3.0)
        var flatDir = Vector3D(i: 1.0, j: 1.0, k: 1.0)
        flatDir.normalize()
        
        let contrail = try! Line(spot: flatOrig, arrow: flatDir)
        
        let trialOff = Point3D(x: 1.0, y: 2.0, z: 4.0)
        
        XCTAssertFalse(Line.isCoincident(straightA: contrail, trial: trialOff))
        
        
        let trialOn = Point3D(x: 3.5, y: 4.5, z: 5.5)
        
        XCTAssert(Line.isCoincident(straightA: contrail, trial: trialOn))
        
        
        let trialCoin = Point3D(x: 1.0, y: 2.0, z: 3.0)
        
        XCTAssert(Line.isCoincident(straightA: contrail, trial: trialCoin))
        
    }
    
    func testDropPoint()   {
        
        let trailhead = Point3D(x: 4.0, y: 2.0, z: 1.0)
        var compass = Vector3D(i: 1.0, j: 1.0, k: 1.0)
        compass.normalize()
        
        var rocket = try! Line(spot: trailhead, arrow: compass)
        
        var incoming = Point3D(x: 6.0, y: 4.0, z: 3.0)
        var splat = rocket.dropPoint(away: incoming)
        
        XCTAssert(splat == incoming)
        
        
        compass = Vector3D(i: 1.0, j: 1.0, k: 0.0)
        compass.normalize()
        
        rocket = try! Line(spot: trailhead, arrow: compass)
        
        incoming = Point3D(x: 5.0, y: 3.0, z: 0.0)
        let target = Point3D(x: 5.0, y: 3.0, z: 1.0)
        
        splat = rocket.dropPoint(away: incoming)
        
        XCTAssert(splat == target)
        
    }
    
    func testIsCoincidentLine()   {
        
        let gOrig = Point3D(x: 5.0, y: 8.5, z: -1.25)
        var gDir = Vector3D(i: -1.0, j: -1.0, k: -1.0)
        gDir.normalize()
        
        let redstone = try! Line(spot: gOrig, arrow: gDir)
        
        let pOrig = Point3D(x: 3.0, y: 6.5, z: -3.25)
        var pDir = Vector3D(i: -1.0, j: -1.0, k: -1.0)
        pDir.normalize()
        
        let titan = try! Line(spot: pOrig, arrow: pDir)
        
        XCTAssert(Line.isCoincident(straightA: redstone, straightB: titan))
        
        
        pDir = Vector3D(i: -1.0, j: 1.0, k: 1.0)
        pDir.normalize()
        
        let atlas = try! Line(spot: pOrig, arrow: pDir)
        XCTAssertFalse(Line.isCoincident(straightA: redstone, straightB: atlas))

    }
    
    
    func testIntersectTwo()   {
        
        let flatOrig = Point3D(x: 1.0, y: 0.0, z: 0.0)
        let flatDir = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let P51Orig = Point3D(x: 3.0, y: 1.0, z: 0.0)
        var P51Dir = Vector3D(i: -0.707, j: 0.707, k: 0.0)
        P51Dir.normalize()
        
        let target = Point3D(x: 1.0, y: 3.0, z: 0.0)
        
        do   {
            
            let flat = try Line(spot: flatOrig, arrow: flatDir)
            let pursuit = try Line(spot: P51Orig, arrow: P51Dir)
            
            let crossroads = try Line.intersectTwo(straightA: flat, straightB: pursuit)
            
            XCTAssert(crossroads == target)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Line Intersect Two A")
        }
        
        let roofOrig = Point3D(x: 0.0, y: 0.0, z: 3.85)
        let roofDir = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let evelOrig = Point3D(x: -1.5, y: 0.0, z: 1.5)
        var evelDir = Vector3D(i: -0.707, j: 0.0, k: 0.707)
        evelDir.normalize()
        
        let target2 = Point3D(x: -3.85, y: 0.0, z: 3.85)
        
        do   {
            
            let flat = try Line(spot: roofOrig, arrow: roofDir)
            let pursuit = try Line(spot: evelOrig, arrow: evelDir)
            
            let crossroads = try Line.intersectTwo(straightA: flat, straightB: pursuit)
            
            print(crossroads)
            
            XCTAssert(crossroads == target2)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Line Intersect Two B")
        }
        
        
    }

    func testResolvePoint()   {
        
        let orig = Point3D(x: 2.0, y: 1.5, z: 0.0)
        let thataway = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let refLine = try! Line(spot: orig, arrow: thataway)
        
        let targetA = -2.0
        let targetP = 1.0
        
        let target = (targetA, targetP)
        
        let trial = Point3D(x: 0.0, y: 0.5, z: 0.0)
        let comps = refLine.resolveRelative(yonder: trial)
        
        XCTAssert(comps == target)
    }
    
}
