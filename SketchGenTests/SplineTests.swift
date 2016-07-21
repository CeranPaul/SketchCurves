//
//  SplineTests.swift
//  SketchCurves
//
//  Created by Paul H on 7/18/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class SplineTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {

        var lilyPads = [Point3D]()
        
        let a = Point3D(x: 0.25, y: -1.5, z: 4.2)
        lilyPads.append(a)
        
        let b = Point3D(x: 0.55, y: -0.75, z: 4.2)
        lilyPads.append(b)
        
        let c = Point3D(x: 0.80, y: -0.15, z: 4.2)
        lilyPads.append(c)
        
        let d = Point3D(x: 0.40, y: 0.15, z: 4.2)
        lilyPads.append(d)
        
        let e = Point3D(x: -0.10, y: 0.65, z: 4.2)
        lilyPads.append(e)
        
        let swing = Spline(pts: lilyPads)
        
        let target = 4
        
        let trial = swing.pieces.count
        
        XCTAssertEqual(trial, target)
        
   }


}
