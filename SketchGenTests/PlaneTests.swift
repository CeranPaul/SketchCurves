//
//  PlaneTests.swift
//  SketchCurves
//
//  Created by Paul on 12/10/15.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
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
    
    func testResolveRelative()   {
        
           // Test coincident case
        let pOrig = Point3D(x: -1.2, y: 3.1, z: 5.0)
        let pNorm = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        var trial = Point3D(x: -1.2, y: 3.1, z: 5.0)
        
        var streets = flat.resolveRelative(pip: trial)
        
        XCTAssert(streets.inPlane.isZero())
        XCTAssert(streets.perp.isZero())
        
        
        trial = Point3D(x: -4.2, y: 7.1, z: 5.0)
        streets = flat.resolveRelative(pip: trial)
        
        XCTAssert(streets.inPlane.length() == 5.0)
        XCTAssert(streets.perp.isZero())

        
        trial = Point3D(x: -1.2, y: 3.1, z: 8.0)
        streets = flat.resolveRelative(pip: trial)
        
        XCTAssert(streets.perp.length() == 3.0)
        XCTAssert(streets.inPlane.isZero())
        
    }
    
    func testIsParallelLine()   {
        
        let pOrig = Point3D(x: -1.2, y: 3.1, z: 5.0)
        var pNorm = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        let gOrig = Point3D(x: 5.0, y: 3.1, z: 4.0)
        var gNorm = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        var heli = try! Line(spot: gOrig, arrow: gNorm)
        
        XCTAssert(Plane.isParallel(flat: flat, enil: heli))
        
        gNorm = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        heli = try! Line(spot: gOrig, arrow: gNorm)
        
        XCTAssert(Plane.isParallel(flat: flat, enil: heli))
        

        gNorm = Vector3D(i: 0.707, j: 0.707, k: 0.0)
        gNorm.normalize()
        heli = try! Line(spot: gOrig, arrow: gNorm)
        
        XCTAssert(Plane.isParallel(flat: flat, enil: heli))
        
        
        pNorm = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let flat2 = try! Plane(spot: pOrig, arrow: pNorm)
        
        XCTAssertFalse(Plane.isParallel(flat: flat2, enil: heli))
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
    
    func testIsCoincidentLine()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let playingField = try! Plane(spot: nexus, arrow: horn)
        
        let gOrig = Point3D(x: 5.0, y: 3.1, z: 4.0)
        var gNorm = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        var heli = try! Line(spot: gOrig, arrow: gNorm)
        
        XCTAssertFalse(Plane.isCoincident(enalp: playingField, enil: heli))
        
        let gOrig2 = Point3D(x: 2.0, y: 3.5, z: 6.0)
        gNorm = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        heli = try! Line(spot: gOrig2, arrow: gNorm)

        XCTAssert(Plane.isCoincident(enalp: playingField, enil: heli))
        
    }
    
    func testIsParallelPlane()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let playingField = try! Plane(spot: nexus, arrow: horn)
        
        let pOrig = Point3D(x: -1.2, y: 3.1, z: 5.0)
        var pNorm = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        var flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        XCTAssertFalse(Plane.isParallel(lhs: flat, rhs: playingField))
        
        
        pNorm = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        XCTAssert(Plane.isParallel(lhs: flat, rhs: playingField))
                
    }
    
    func testIsCoincidentPlane()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let playingField = try! Plane(spot: nexus, arrow: horn)
        
        var pOrig = Point3D(x: -1.2, y: 3.1, z: 5.0)
        var pNorm = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        var flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        XCTAssertFalse(Plane.isCoincident(lhs: flat, rhs: playingField))
        
        
        // Parallel, but not coincident
        pNorm = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        XCTAssertFalse(Plane.isCoincident(lhs: flat, rhs: playingField))
        
        
        pOrig = Point3D(x: 2.0, y: 3.1, z: 5.0)
        flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        XCTAssert(Plane.isCoincident(lhs: flat, rhs: playingField))
        
    }
    
    
    func testIntersectLinePlane()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let groundFloor = try! Plane(spot: nexus, arrow: horn)
        
        var gOrig = Point3D(x: 5.0, y: 3.1, z: 4.0)
        var gNorm = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        var heli = try! Line(spot: gOrig, arrow: gNorm)
        
        do   {
            
            _ = try Plane.intersectLinePlane(enil: heli, enalp: groundFloor)
            
        }  catch is ParallelError   {
            XCTAssert(true)
        }   catch   {
            print("Unexpected journey!")
        }
        
        gNorm = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        heli = try! Line(spot: gOrig, arrow: gNorm)

        var target = Point3D(x: 2.0, y: 3.1, z: 4.0)
        
        var pierce = try! Plane.intersectLinePlane(enil: heli, enalp: groundFloor)
        
        XCTAssert(pierce == target)

        
        gOrig = Point3D(x: 2.0, y: 3.7, z: 6.0)
        heli = try! Line(spot: gOrig, arrow: gNorm)
        
        target = Point3D(x: 2.0, y: 3.7, z: 6.0)

        pierce = try! Plane.intersectLinePlane(enil: heli, enalp: groundFloor)
        
        XCTAssert(pierce == target)
        
    }
    
    func testIntersectPlanes()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let groundFloor = try! Plane(spot: nexus, arrow: horn)
        
        var pOrig = Point3D(x: -1.2, y: 3.1, z: 5.0)
        var pNorm = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let flat = try! Plane(spot: pOrig, arrow: pNorm)
        
        do   {
            
            _ = try Plane.intersectPlanes(flatA: groundFloor, flatB: flat)
            
        }   catch is ParallelPlanesError   {
            XCTAssert(true)
        }   catch  {
            print("Unexpected journey!")
        }
        
        let dupe = try! Plane(spot: nexus, arrow: horn)
        
        do   {
            
            _ = try Plane.intersectPlanes(flatA: groundFloor, flatB: dupe)
            
        }   catch is CoincidentPlanesError   {
            XCTAssert(true)
        }   catch  {
            print("Unexpected journey!")
        }
        
        
        pOrig = Point3D(x: -1.2, y: 3.1, z: 5.0)
        pNorm = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let flat2 = try! Plane(spot: pOrig, arrow: pNorm)
        
        let slash = try! Plane.intersectPlanes(flatA: groundFloor, flatB: flat2)
        
        let targetVect = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let flag = slash.getDirection() == targetVect || Vector3D.isOpposite(lhs: slash.getDirection(), rhs: targetVect)
        
        XCTAssert(flag)
        
    }
    
    func testProjectToPlane()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let playingField = try! Plane(spot: nexus, arrow: horn)
        
            // Test a point that already lies on the plane
        var standoff = Point3D(x: 2.0, y: 5.0, z: 3.5)
        
        var trial = Plane.projectToPlane(pip: standoff, enalp: playingField)
        
        var target = Point3D(x: 2.0, y: 5.0, z: 3.5)
        
        XCTAssert(trial == target)
        
        
        standoff = Point3D(x: 1.0, y: -1.2, z: 3.15)
        
        trial = Plane.projectToPlane(pip: standoff, enalp: playingField)
        
        target = Point3D(x: 2.0, y: -1.2, z: 3.15)
        
        XCTAssert(trial == target)
        
    }
    
    func testBuildParallel()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let groundFloor = try! Plane(spot: nexus, arrow: horn)
        
        let build1 = Plane.buildParallel(base: groundFloor, offset: 1.2, reverse: false)
        
        XCTAssert(Plane.isParallel(lhs: groundFloor, rhs: build1))
        
        let diff = groundFloor.resolveRelative(pip: build1.getLocation())
        
        XCTAssert(Plane.isParallel(lhs: groundFloor, rhs: build1))
        XCTAssertEqual(diff.perp.length(), 1.2, accuracy: Vector3D.EpsilonV)
        
        
        let build2 = Plane.buildParallel(base: groundFloor, offset: 1.2, reverse: true)
        
        XCTAssert(Vector3D.isOpposite(lhs: groundFloor.getNormal(), rhs: build2.getNormal()))

        
    }
    
    func testBuildPerpThroughLine()   {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        let horn = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let groundFloor = try! Plane(spot: nexus, arrow: horn)
        
        var gOrig = Point3D(x: 5.0, y: 3.1, z: 4.0)
        let gNorm = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        var heli = try! Line(spot: gOrig, arrow: gNorm)
        
        XCTAssertFalse(Plane.isCoincident(enalp: groundFloor, enil: heli))
        
        do   {
            
            _ = try Plane.buildPerpThruLine(enil: heli, enalp: groundFloor)
            
        }   catch is CoincidentLinesError   {
            XCTAssert(true)
        }   catch   {
            print("Unexpected journey")
        }
        
        gOrig = Point3D(x: 2.0, y: 3.1, z: 4.7)
        heli = try! Line(spot: gOrig, arrow: gNorm)

        XCTAssert(Plane.isCoincident(enalp: groundFloor, enil: heli))
        
        let standup = try! Plane.buildPerpThruLine(enil: heli, enalp: groundFloor)

        let targetVect = Vector3D(i: 0.0, j: 1.0, k: 0.0)

        let flag = standup.getNormal() == targetVect || Vector3D.isOpposite(lhs: standup.getNormal(), rhs: targetVect)

        XCTAssert(flag)

    }
    
}
