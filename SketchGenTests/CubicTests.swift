//
//  CubicTests.swift
//  SketchCurves
//
//  Created by Paul on 7/16/16.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class CubicTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHermite() {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        let bump = Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
        let oneTrial = bump.pointAt(t: 0.0)
        
           // Gee, this would be a grand place for an extension of XCTAssert that compares points
        let flag1 = Point3D.dist(pt1: oneTrial, pt2: alpha) < (Point3D.Epsilon / 3.0)
        
        if !flag1  {  XCTFail()  }
        
        let otherTrial = bump.pointAt(t: 1.0)
        let flag2 = Point3D.dist(pt1: otherTrial, pt2: beta) < (Point3D.Epsilon / 3.0)
        
        if !flag2  {  XCTFail()  }
        
    }

    func testBezier()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let control1 = alpha.offset(jump: alSlope)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        let bReverse = betSlope.reverse()
        let control2 = beta.offset(jump: bReverse)
        
        let bump = Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        let oneTrial = bump.pointAt(t: 0.0)
        
        // Gee, this would be a grand place for an extension of XCTAssert that compares points
        let flag1 = Point3D.dist(pt1: oneTrial, pt2: alpha) < (Point3D.Epsilon / 3.0)
        
        XCTAssert(flag1)
        
        let otherTrial = bump.pointAt(t: 1.0)
        let flag2 = Point3D.dist(pt1: otherTrial, pt2: beta) < (Point3D.Epsilon / 3.0)
        
        XCTAssert(flag2)
        
    }
    
    func testExtent()   {
        
        let alpha = Point3D(x: -2.3, y: 1.5, z: 0.7)
        
        let control1 = Point3D(x: -3.1, y: 0.0, z: 0.7)
        
        let control2 = Point3D(x: -3.1, y: -1.6, z: 0.7)
        
        let beta = Point3D(x: -2.7, y: -3.4, z: 0.7)
        
        let bump = Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        
        let box = bump.getExtent()
        
        XCTAssertEqualWithAccuracy(box.getOrigin().x, -2.9624, accuracy: 0.0001)
    }
    
}
