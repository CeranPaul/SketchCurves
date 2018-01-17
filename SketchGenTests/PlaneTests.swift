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

        // A non-unit vector should cause an error
        var horn = Vector3D(i: 0.5, j: 0.5, k: 0.5)
        
        XCTAssertThrowsError(try Plane(spot: nexus, arrow: horn))
        
        // A zero vector should cause an error
        horn = Vector3D(i: 0.0, j: 0.0, k: 0.0)
        
        XCTAssertThrowsError(try Plane(spot: nexus, arrow: horn))
        
        horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        horn.normalize()
        
        let llanoEstacado = try! Plane(spot: nexus, arrow: horn)
        
        XCTAssert(llanoEstacado.getLocation().x == 2.0)
        XCTAssert(llanoEstacado.getLocation().y == 3.0)
        XCTAssert(llanoEstacado.getLocation().z == 4.0)
        
        XCTAssert(llanoEstacado.getNormal().i == 3.0 / 13.0)
        XCTAssert(llanoEstacado.getNormal().j == 4.0 / 13.0)
        XCTAssert(llanoEstacado.getNormal().k == 12.0 / 13.0)
                    
    }
    
    func testInitPts()   {
        
        let huey = Point3D(x: 2.0, y: 3.0, z: 8.0)
        let dewey = Point3D(x: 0.0, y: 3.0, z: -1.0)
        let louie = Point3D(x: 4.0, y: 3.0, z: -1.25)
        
        let constY = try! Plane(alpha: huey, beta: dewey, gamma: louie)
        
        let targetNorm = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let flag1 = constY.getNormal() == targetNorm || Vector3D.isOpposite(lhs: constY.getNormal(), rhs: targetNorm)
        
        XCTAssert(flag1)
        
           // Bad referencing should cause an error
        XCTAssertThrowsError(try Plane(alpha: huey, beta: huey, gamma: louie))
        
        
        let mickey = Point3D(x: 2.0, y: 2.0, z: 2.0)
        let minnie = Point3D(x: 5.0, y: 5.0, z: 5.0)
        let pluto = Point3D(x: 6.5, y: 6.5, z: 6.5)
        
        // Collinear points should cause an error
        XCTAssertThrowsError(try Plane(alpha: mickey, beta: minnie, gamma: pluto))

    }
    
    func testLocationGetter()   {
        
        let target = Point3D(x: 2.0, y: 3.0, z: 4.0)
        
        var nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        horn.normalize()
        
        var llanoEstacado = try! Plane(spot: nexus, arrow: horn)
        
        var pip = llanoEstacado.getLocation()
        
        XCTAssert(pip == target)
        
        
        
        nexus = Point3D(x: 0.25, y: 3.0, z: 4.0)
        
        llanoEstacado = try! Plane(spot: nexus, arrow: horn)
        
        pip = llanoEstacado.getLocation()
        
        XCTAssertFalse(pip == target)
        
        
    }
    
    func testNormalGetter()   {
        
        var target = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        target.normalize()
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        horn.normalize()
        
        var llanoEstacado = try! Plane(spot: nexus, arrow: horn)
        
        var finger = llanoEstacado.getNormal()
        
        XCTAssert(finger == target)
        
        horn = Vector3D(i: 3.0, j: 3.0, k: 12.0)
        horn.normalize()
        
        llanoEstacado = try! Plane(spot: nexus, arrow: horn)
        
        finger = llanoEstacado.getNormal()
        
        XCTAssertFalse(finger == target)
        
    }
    
    /// Verify the overloaded function
    func testEquals()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        horn.normalize()
            
        do   {
            
            let target = try Plane(spot: nexus, arrow: horn)
            

            let llanoEstacado = try Plane(spot: nexus, arrow: horn)
            
            XCTAssert(llanoEstacado == target)
            
            
            var spot = Point3D(x: 2.0, y: 3.0, z: 4.5)
            var thataway = Vector3D(i: 3.0, j: 4.0, k: 12.0)
            thataway.normalize()
            
            let billiardTable = try Plane(spot: spot, arrow: thataway)
            
            XCTAssertFalse(billiardTable == target)
            
            
            spot = Point3D(x: 2.0, y: 3.0, z: 4.0)
            thataway = Vector3D(i: 2.0, j: 4.0, k: 12.0)
            thataway.normalize()
            
            let kansas = try Plane(spot: spot, arrow: thataway)
            
            XCTAssertFalse(kansas == target)
            
            
            spot = Point3D(x: 2.0, y: 3.0, z: 4.0)
            thataway = Vector3D(i: -3.0, j: -4.0, k: -12.0)
            thataway.normalize()
            
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
        
        let playingField = try! Plane(spot: nexus, arrow: horn)
        
        
        var trial = Point3D(x: 2.0, y: 5.0, z: 3.5)
        
        XCTAssert(Plane.isCoincident(flat: playingField, pip: trial))
        
        
        trial = Point3D(x: 1.9, y: 3.0, z: 4.0)
        
        XCTAssertFalse(Plane.isCoincident(flat: playingField, pip: trial))
        
        
        trial = Point3D(x: 2.0, y: 3.0, z: 4.0)
        
        XCTAssert(Plane.isCoincident(flat: playingField, pip: trial))
        
    }
}
