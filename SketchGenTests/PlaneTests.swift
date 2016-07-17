//
//  PlaneTests.swift
//  SketchCurves
//
//  Created by Paul Hollingshead on 12/10/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class PlaneTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Verify the correctness of recording the inputs
    func testFidelity()  {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        try! horn.normalize()   // Safe by inspection
        
        do   {
            
            let llanoEstacado = try Plane(spot: nexus, arrow: horn)
        
            XCTAssert(llanoEstacado.getLocation().x == 2.0)
            XCTAssert(llanoEstacado.getLocation().y == 3.0)
            XCTAssert(llanoEstacado.getLocation().z == 4.0)

            XCTAssert(llanoEstacado.getNormal().i == 3.0 / 13.0)
            XCTAssert(llanoEstacado.getNormal().j == 4.0 / 13.0)
            XCTAssert(llanoEstacado.getNormal().k == 12.0 / 13.0)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Plane")
        }
    }
    
    
    func testLocationGetter()   {
        
        let target = Point3D(x: 2.0, y: 3.0, z: 4.0)
        
        var nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        try! horn.normalize()   // Safe by inspection
        
        do   {
            
            var llanoEstacado = try Plane(spot: nexus, arrow: horn)
            
            var pip = llanoEstacado.getLocation()
            
            XCTAssert(pip == target)
            
            
            
            nexus = Point3D(x: 0.25, y: 3.0, z: 4.0)
            
            llanoEstacado = try Plane(spot: nexus, arrow: horn)
            
            pip = llanoEstacado.getLocation()
            
            XCTAssertFalse(pip == target)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Plane: Getter A")
        }
        
    }
    
    func testNormalGetter()   {
        
        var target = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        try! target.normalize()   // Safe by inspection
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        try! horn.normalize()   // Safe by inspection
        
        do   {
            
            var llanoEstacado = try Plane(spot: nexus, arrow: horn)
            
            var finger = llanoEstacado.getNormal()
            
            XCTAssert(finger == target)
            
            var horn = Vector3D(i: 3.0, j: 3.0, k: 12.0)
            try! horn.normalize()   // Safe by inspection
            
            llanoEstacado = try Plane(spot: nexus, arrow: horn)
            
            finger = llanoEstacado.getNormal()
            
            XCTAssertFalse(finger == target)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Plane: Getter B")
        }
        
    }
    
    /// Verify the overloaded function
    func testEquals()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        try! horn.normalize()   // Safe by inspection
            
        do   {
            
            let target = try Plane(spot: nexus, arrow: horn)
            

            let llanoEstacado = try Plane(spot: nexus, arrow: horn)
            
            XCTAssert(llanoEstacado == target)
            
            
            var spot = Point3D(x: 2.0, y: 3.0, z: 4.5)
            var thataway = Vector3D(i: 3.0, j: 4.0, k: 12.0)
            try! thataway.normalize()   // Safe by inspection
            
            let billiardTable = try Plane(spot: spot, arrow: thataway)
            
            XCTAssertFalse(billiardTable == target)
            
            
            spot = Point3D(x: 2.0, y: 3.0, z: 4.0)
            thataway = Vector3D(i: 2.0, j: 4.0, k: 12.0)
            try! thataway.normalize()   // Safe by inspection
            
            let kansas = try Plane(spot: spot, arrow: thataway)
            
            XCTAssertFalse(kansas == target)
            
            
            spot = Point3D(x: 2.0, y: 3.0, z: 4.0)
            thataway = Vector3D(i: -3.0, j: -4.0, k: -12.0)
            try! thataway.normalize()   // Safe by inspection
            
            let runway = try Plane(spot: spot, arrow: thataway)
            
            XCTAssertFalse(runway == target)
            
            
        }   catch let rorre as NonUnitDirectionError    {
            print(rorre.description)
            
        }   catch let rorre as ZeroVectorError    {
            print(rorre.description)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Plane Equals")
        }
    }
    
    
    func testIsCoincident()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        do   {
            
            let playingField = try Plane(spot: nexus, arrow: horn)
            
            var trial = Point3D(x: 2.0, y: 5.0, z: 3.5)
            
            XCTAssert(Plane.isCoincident(playingField, pip: trial))
            
            
            trial = Point3D(x: 1.9, y: 3.0, z: 4.0)
            
            XCTAssertFalse(Plane.isCoincident(playingField, pip: trial))
            
            
            trial = Point3D(x: 2.0, y: 3.0, z: 4.0)
            
            XCTAssert(Plane.isCoincident(playingField, pip: trial))
            
       }   catch   {
            print("Did you really throw an error in a test case?  Plane Equals")
        }
    }
}
