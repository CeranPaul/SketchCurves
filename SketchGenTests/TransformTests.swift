//
//  TransformTests.swift
//  SketchCurves
//
//  Created by Paul Hollingshead on 1/18/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest
import simd

class TransformTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTranslate() {
        
        let originalPt = Point3D(x: 2.5, y: -5.0, z: 1.25)
        
        let pip = double4(originalPt.x, originalPt.y, originalPt.z, 1.0)

        let tform = Transform(deltaX: -1.0, deltaY: 3.0, deltaZ: 0.375)
        
        let mtxProduct = pip * tform.mtx
        
        let transformed = Point3D(x: mtxProduct[0], y: mtxProduct[1], z: mtxProduct[2])
        
        let target = Point3D(x: 1.5, y: -2.0, z: 1.625)
        
        XCTAssert(transformed == target)
    }
    

    func testScale()   {
        
        let originalPt = Point3D(x: -3.0, y: -5.0, z: 1.75)
        
        let pip = double4(originalPt.x, originalPt.y, originalPt.z, 1.0)
        
        var tform = Transform(scaleX: 1.0, scaleY: -1.0, scaleZ: 1.0)
        
        var mtxProduct = pip * tform.mtx
        
        var transformed = Point3D(x: mtxProduct[0], y: mtxProduct[1], z: mtxProduct[2])
        
        
        let target = Point3D(x: -3.0, y: 5.0, z: 1.75)
        
        XCTAssert(transformed == target)
        
        
        tform = Transform(scaleX: 4.0, scaleY: 4.0, scaleZ: 4.0)
        
        mtxProduct = pip * tform.mtx
        
        transformed = Point3D(x: mtxProduct[0], y: mtxProduct[1], z: mtxProduct[2])
        
        let target2 = Point3D(x: -12.0, y: -20.0, z: 7.0)
        
        XCTAssert(transformed == target2)
        
    }
    
    
    func testRotate()   {
        
        let Squirt2 = sqrt(2.0)   // Used in several comparisons
        
        
        var originalPt = Point3D(x: 3.0, y: 3.0, z: 3.0)
        
        var pip = double4(originalPt.x, originalPt.y, originalPt.z, 1.0)
        
        var tform = Transform(rotationAxis: Axis.Y, angleRad: M_PI / 2)
        
        var mtxProduct = pip * tform.mtx
        
        var transformed = Point3D(x: mtxProduct[0], y: mtxProduct[1], z: mtxProduct[2])        
        
        let target = Point3D(x: 3.0, y: 3.0, z: -3.0)
        
        XCTAssert(transformed == target)
        
        

        
        tform = Transform(rotationAxis: Axis.X, angleRad: M_PI / 4)
        
        mtxProduct = pip * tform.mtx
        
        transformed = Point3D(x: mtxProduct[0], y: mtxProduct[1], z: mtxProduct[2])
        
        let target2 = Point3D(x: 3.0, y: 0.0, z: 3.0 * Squirt2)
        
        XCTAssert(transformed == target2)
        
        
        
        tform = Transform(rotationAxis: Axis.Z, angleRad: M_PI / 4)
        
        mtxProduct = pip * tform.mtx
        
        transformed = Point3D(x: mtxProduct[0], y: mtxProduct[1], z: mtxProduct[2])
        
        let target3 = Point3D(x: 0.0, y: 3.0 * Squirt2, z: 3.0)
        
        XCTAssert(transformed == target3)
        
        
        tform = Transform(rotationAxis: Axis.Z, angleRad: M_PI / 2)
        
        originalPt = Point3D(x: 3.0, y: 0.0, z: 3.0)
        
        pip = double4(originalPt.x, originalPt.y, originalPt.z, 1.0)
        
        let target4 = Point3D(x: 0.0, y: 3.0, z: 3.0)
        
        mtxProduct = pip * tform.mtx
        
        transformed = Point3D(x: mtxProduct[0], y: mtxProduct[1], z: mtxProduct[2])
        
        XCTAssert(transformed == target4)
        
    }
    

}
