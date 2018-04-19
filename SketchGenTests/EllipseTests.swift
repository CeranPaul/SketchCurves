//
//  EllipseTests.swift
//  SketchGenTests
//
//  Created by Paul Hollingshead on 4/19/18.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.
//

import XCTest

class EllipseTests: XCTestCase {
    
    var egg: Ellipse?
    
    override func setUp() {
        super.setUp()
        
        let nexus = Point3D(x: 1.5, y: 0.25, z: 2.0)
        let aLength = 4.0
        let bLength = 2.5
        
        let longDir = Double.pi / 2.0
        let startFinish = Point3D(x: 1.5, y: 2.25, z: 2.0)
        
        let rocket = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        egg = Ellipse(retnec: nexus, a: aLength, b: bLength, azimuth: longDir, start: startFinish, finish: startFinish, normal: rocket)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testGetters()   {
        
        let alpha = Point3D(x: 1.5, y: 2.25, z: 2.0)
        let retAlpha = egg!.getOneEnd()
        XCTAssertEqual(alpha, retAlpha)
        
        let retBeta = egg!.getOtherEnd()
        XCTAssertEqual(alpha, retBeta)
        
        let beta = Point3D(x: 1.5, y: 0.25, z: 2.0)
        XCTAssertEqual(egg!.getCenter(), beta)
        
    }
    
    
    func testSetIntent()   {
        
        XCTAssert(egg!.usage == PenTypes.ordinary)
        
        egg!.setIntent(purpose: PenTypes.ideal)
        XCTAssert(egg!.usage == PenTypes.ideal)
        
    }
    
    

    
}
