//
//  SplineTests.swift
//  SketchCurves
//
//  Created by Paul on 7/18/16.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class SplineTests: XCTestCase {

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
