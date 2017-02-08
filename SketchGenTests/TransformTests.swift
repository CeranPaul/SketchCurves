//
//  TransformPlusTests.swift
//  SketchCurves
//
//  Created by Paul on 2/14/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class TransformPlusTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSingleRotations() {

        let fodder = Point3D(x: 2.0, y: 0.0, z: 0.0)
        let rowA = RowMtx4(ptIn: fodder)
        
        var simpleRot = Transform(rotationAxis: Axis.x, angleRad: M_PI_4)
        
        var multRes = rowA * simpleRot
        
        var transformed = multRes.toPoint()
        
        
        /// A handy factor in order to get precise comparisons
        let sq2rt = sqrt(2.0)
        
        let target1 = Point3D(x: 2.0, y: 0.0, z: 0.0)
        
        XCTAssert(transformed == target1)
        
        
        simpleRot = Transform(rotationAxis: Axis.y, angleRad: M_PI_4)
        
        multRes = rowA * simpleRot
        
        transformed = multRes.toPoint()
        
        let target2 = Point3D(x: sq2rt, y: 0.0, z: -sq2rt)
        
        XCTAssert(transformed == target2)
        
        
        
        simpleRot = Transform(rotationAxis: Axis.z, angleRad: M_PI_4)
        
        multRes = rowA * simpleRot
        
        transformed = multRes.toPoint()
        
        let target3 = Point3D(x: sq2rt, y: sq2rt, z: 0.0)
       
        XCTAssert(transformed == target3)
        
    }

    func testRollYourOwn() {
        
        let fodder = Point3D(x: 2.0, y: 0.0, z: 0.0)
        let rowA = RowMtx4(ptIn: fodder)
        
        /// A handy factor in order to get precise comparisons
        let sq2rt = sqrt(2.0)
        let halfSq2rt = sq2rt / 2.0
        
           // Generate an equivalent to a rotation around the Z axis
        let freshXAxis = Vector3D(i: halfSq2rt, j: halfSq2rt, k: 0.0)
        let freshYAxis = Vector3D(i: -halfSq2rt, j: halfSq2rt, k: 0.0)
        let freshZAxis = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let hardRot = Transform(localX: freshXAxis, localY: freshYAxis, localZ: freshZAxis)
        
        let multRes = rowA * hardRot
        
        let transformed = multRes.toPoint()
        
        let target3 = Point3D(x: sq2rt, y: sq2rt, z: 0.0)
        
        XCTAssert(transformed == target3)
        
        
        
    }
    
}
