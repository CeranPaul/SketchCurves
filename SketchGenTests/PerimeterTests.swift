//
//  PerimeterTests.swift
//  SketchCurves
//
//  Created by Paul Hollingshead on 1/21/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class PerimeterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOrdering() {
        
           // Create points for a sample perimeter
        let alum = Point3D(x: 2.5, y: 1.5, z: 3.0)
        let steel = Point3D(x: 8.5, y: 6.5, z: 3.0)
        let rubber = Point3D(x: 9.5, y: 5.0, z: 3.0)
        let acrylic = Point3D(x: 7.0, y: 0.0, z: 3.0)
        let leather = Point3D(x: 4.0, y: 0.0, z: 3.0)
        
           // Create line segments for a sample perimeter
        let liberator = try! LineSeg(end1: alum, end2: steel)
        let mustang = try! LineSeg(end1: steel, end2: rubber)
        let fortress = try! LineSeg(end1: rubber, end2: acrylic)
        let lightning = try! LineSeg(end1: acrylic, end2: leather)
        let thunderbolt = try! LineSeg(end1: leather, end2: alum)
        
        let fence = Perimeter()
        
        fence.add(liberator)
        fence.add(mustang)
        fence.add(fortress)
        fence.add(lightning)
        
        
        XCTAssertFalse(fence.isClosed())
        
        fence.add(thunderbolt)
        
        let target = 5
        let trial = fence.pieces.count
        
        XCTAssertEqual(trial, target)
        
        XCTAssertTrue(fence.isClosed())
        
        
        let fence2 = Perimeter()
        
        fence2.add(liberator)
        mustang.reverse()
        fence2.add(mustang)   // The 'add' routine should reverse this when adding to the array
        fence2.add(fortress)
        fence2.add(lightning)
        fence2.add(thunderbolt)
        
        XCTAssertTrue(fence2.isClosed())
        
        
        let fence3 = Perimeter()
        
        liberator.reverse()
        fence3.add(liberator)
        mustang.reverse()
        fence3.add(mustang)
        fortress.reverse()
        fence3.add(fortress)
        lightning.reverse()
        fence3.add(lightning)
        thunderbolt.reverse()
        fence3.add(thunderbolt)
        
        XCTAssertTrue(fence3.isClosed())
    }

}
