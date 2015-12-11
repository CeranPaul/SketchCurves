//
//  Point3DTests.swift
//  CurveLab
//
//  Created by Paul Hollingshead on 11/5/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
//

import XCTest

class Point3DTests: XCTestCase {

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
        
        let sample = Point3D(x: 8.0, y: 6.0, z: 4.0)
        
        XCTAssert(sample.x == 8.0)
        XCTAssert(sample.y == 6.0)
        XCTAssert(sample.z == 4.0)
    }

    func testOffset()   {
        
        let local = Point3D(x: -1.0, y: 2.0, z: -3.0)
        
        let jump = Vector3D(i: 1.5, j: 1.5, k: 1.5)
        
        let tip = local.offset(jump)
        
        XCTAssert(tip.x == 0.5)
        XCTAssert(tip.y == 3.5)
        XCTAssert(tip.z == -1.5)
    }
    
    /// Verify the distance function
    func testDist()   {
        
        let here = Point3D(x: -10.0, y: -5.0, z: -23.0)
        let there = Point3D(x: -7.0, y: -9.0, z: -11.0)
        
        let sep = Point3D.dist(here, pt2: there)
        
        XCTAssert(sep == 13.0)
    }
}
