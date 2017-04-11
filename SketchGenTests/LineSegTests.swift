//
//  LineSegTests.swift
//  SketchCurves
//
//  Created by Paul Hollingshead on 11/3/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class LineSegTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /// Test a point at some proportion along the line segment
    func testPointAt() {
        
        let pt1 = Point3D(x: 1.0, y: 1.0, z: 1.0)
        let pt2 = Point3D(x: 5.0, y: 5.0, z: 5.0)
        
        do   {
            
            let slash = try LineSeg(end1: pt1, end2: pt2)
        
            let ladybug = slash.pointAt(t: 0.6)
            
            let home = Point3D(x: 3.4, y: 3.4, z: 3.4)
            
            XCTAssert(ladybug == home)
            
            
        }  catch is CoincidentPointsError  {
            print("Dude, you screwed up!")
        }  catch  {
            print("Some other error while testing a line")
        }
        
    }
    
    func testCoincident()   {
        
        let pt1 = Point3D(x: 1.0, y: 1.0, z: 1.0)
        let pt2 = Point3D(x: 5.0, y: 4.0, z: 6.0)
        
        
        do   {
            
            let slash = try LineSeg(end1: pt1, end2: pt2)
            XCTAssert(true)
            
            XCTAssertNotNil(slash)    // Dummy test to avoid compiler warning three lines above
            
        }  catch is CoincidentPointsError  {
            XCTAssert(false)
        }  catch  {
            print("Some other goof while testing a line")
        }
        
        let pt3 = Point3D(x: 5.0, y: 4.0, z: 6.0)
       
        do   {
            
            let slash = try LineSeg(end1: pt2, end2: pt3)
            XCTAssert(false)
            
            XCTAssertNotNil(slash)    // Dummy test to avoid compiler warning three lines above
            
        }  catch is CoincidentPointsError  {
            XCTAssert(true)
        }  catch  {
            print("Some other logic screw-up while testing a line")
        }
        
    }

    func testLength()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let bar = try! LineSeg(end1: alpha, end2: beta)
        
        let target = 2.0
        
        XCTAssertEqual(bar.getLength(), target)
    }
    

    func testReverse()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 4.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        stroke.reverse()
        
        XCTAssertEqual(alpha, stroke.getOtherEnd())
        XCTAssertEqual(beta, stroke.getOneEnd())
    }
    
    
    func testClipTo()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let cliff = Point3D(x: 4.0, y: 4.0, z: 2.5)
        
        let shorter = stroke.clipTo(stub: cliff, keepNear: true)
        
        let target = 1.5 * sqrt(2.0)
        
        XCTAssertEqualWithAccuracy(target, shorter.getLength(), accuracy: 0.00001)
        
    }
    
    func testResolveRelative()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let pip = Point3D(x: 3.5, y: 3.0, z: 2.5)
        
        let offset = stroke.resolveNeighbor(speck: pip)
        
        
        let targetA = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let targetP = Vector3D(i: 0.0, j: 0.5, k: 0.0)
        
        XCTAssertEqual(offset.along, targetA)
        XCTAssertEqual(offset.perp, targetP)
        
    }
    
    func testIsCrossing()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 2.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let chopA = Point3D(x: 2.4, y: 2.8, z: 2.5)
        let chopB = Point3D(x: 2.6, y: 2.7, z: 2.5)
        
        let chop = try! LineSeg(end1: chopA, end2: chopB)
        
        let flag1 = stroke.isCrossing(chop: chop)
        
        XCTAssert(flag1)
        
    }
    
    func testIntersectLine()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let plateau = try! LineSeg(end1: ptA, end2: ptB)
        
        var launcher = Point3D(x: 3.0, y: -1.0, z: 5.0)
        var azimuth = Vector3D(i: 0.0, j: -1.0, k: 0.0)
        
        var shot = try! Line(spot: launcher, arrow: azimuth)
        
        let target = Point3D(x: 3.0, y: 3.0, z: 5.0)
        
        let crater = plateau.intersect(ray: shot)
        
        XCTAssertEqual(crater.first!, target)
        
        launcher = Point3D(x: 1.0, y: -1.0, z: 5.0)
        shot = try! Line(spot: launcher, arrow: azimuth)
        
        let crater2 = plateau.intersect(ray: shot)
   
        XCTAssert(crater2.isEmpty)
        

        launcher = Point3D(x: 1.0, y: -3.0, z: 5.0)
        azimuth = Vector3D(i: -0.5, j: 0.866, k: 0.0)
        shot = try! Line(spot: launcher, arrow: azimuth)
        
        let crater3 = plateau.intersect(ray: shot)
        
        XCTAssert(crater3.isEmpty)

    }
    
}
