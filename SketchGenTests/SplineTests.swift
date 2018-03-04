//
//  SplineTests.swift
//  SketchCurves
//
//  Created by Paul on 7/18/16.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class SplineTests: XCTestCase {

    var river: Spline?   // For simple tests
    
    override func setUp() {
        super.setUp()
        
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
        
        river = Spline(pts: lilyPads)
        

    }
    
    func testFidelity() {

        let target = 4
        
        let trial = river!.pieces.count
        
        XCTAssertEqual(trial, target)
        
   }
    
    func testGetOneEnd()   {
        
        let a = Point3D(x: 0.25, y: -1.5, z: 4.2)

        let alpha = river!.getOneEnd()
                
        XCTAssert(alpha == a)
    }

    func testGetOtherEnd()   {
        
        let e = Point3D(x: -0.10, y: 0.65, z: 4.2)

        let omega = river!.getOtherEnd()
        
        XCTAssert(omega == e)
   }
    

}
