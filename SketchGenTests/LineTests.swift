//
//  LineTests.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 12/10/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
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
        
        do   {
            
            let contrail = try Line(spot: nexus, arrow: horn)
            
            XCTAssert(contrail.getOrigin().x == -2.5)
            XCTAssert(contrail.getOrigin().y == 1.5)
            XCTAssert(contrail.getOrigin().z == 0.015)
            
            XCTAssert(contrail.getDirection().i == 12.0 / 13.0)
            XCTAssert(contrail.getDirection().j == 3.0 / 13.0)
            XCTAssert(contrail.getDirection().k == 4.0 / 13.0)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Line")
        }
    }
    
    func testIntersectTwo()   {
        
        let flatOrig = Point3D(x: 1.0, y: 0.0, z: 0.0)
        let flatDir = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let P51Orig = Point3D(x: 3.0, y: 1.0, z: 0.0)
        var P51Dir = Vector3D(i: -0.707, j: 0.707, k: 0.0)
        P51Dir.normalize()
        
        let target = Point3D(x: 1.0, y: 3.0, z: 0.0)
        
        do   {
            
            var flat = try Line(spot: flatOrig, arrow: flatDir)
            var pursuit = try Line(spot: P51Orig, arrow: P51Dir)
            
            var crossroads = try Line.intersectTwo(flat, straightB: pursuit)
            
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
            
            var flat = try Line(spot: roofOrig, arrow: roofDir)
            var pursuit = try Line(spot: evelOrig, arrow: evelDir)
            
            var crossroads = try Line.intersectTwo(flat, straightB: pursuit)
            
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
        let comps = refLine.resolveRelative(trial)
        
        XCTAssert(comps == target)
    }
    
}
