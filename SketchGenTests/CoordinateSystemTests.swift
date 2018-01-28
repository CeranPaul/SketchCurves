//
//  CoordinateSystemTests.swift
//  SketchCurves
//
//  Created by Paul on 4/26/17.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class CoordinateSystemTests: XCTestCase {
    
    func testFidelity() {
        
        let home = Point3D(x: 5.0, y: 2.0, z: 1.0)
        
        let sqrt22 = sqrt(2.0) / 2.0
        
        let axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        let axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        let axis3 = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let rotZ = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        let targetOrig = Point3D(x: 5.0, y: 2.0, z: 1.0)
        
        XCTAssert(rotZ.origin == targetOrig)
        
    }
    
}
