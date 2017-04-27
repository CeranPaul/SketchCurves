//
//  PerimeterTests.swift
//  SketchCurves
//
//  Created by Paul on 1/21/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class PerimeterTests: XCTestCase {

    /// Airplane names used as curves
    var liberator, mustang, fortress, lightning, thunderbolt: LineSeg?
    
    override func setUp() {
        super.setUp()
        
           // Create points for a sample perimeter
        let alum = Point3D(x: 2.5, y: 1.5, z: 3.0)
        let steel = Point3D(x: 8.5, y: 6.5, z: 3.0)
        let rubber = Point3D(x: 9.5, y: 5.0, z: 3.0)
        let acrylic = Point3D(x: 7.0, y: 0.0, z: 3.0)
        let leather = Point3D(x: 4.0, y: 0.0, z: 3.0)
        
           // Create line segments for a sample perimeter
        liberator = try! LineSeg(end1: alum, end2: steel)
        mustang = try! LineSeg(end1: steel, end2: rubber)
        fortress = try! LineSeg(end1: rubber, end2: acrylic)
        lightning = try! LineSeg(end1: acrylic, end2: leather)
        thunderbolt = try! LineSeg(end1: leather, end2: alum)
        
    }
    
    /// Test curve capture plus ordering
    func testOrdering() {
        
        let fence = Perimeter()
        
        fence.add(noob: liberator!)
        fence.add(noob: mustang!)
        fence.add(noob: fortress!)
        fence.add(noob: lightning!)
        
        
        XCTAssertFalse(fence.isClosed())
        
        fence.add(noob: thunderbolt!)
        
        let target = 5
        let trial = fence.pieces.count
        
        XCTAssertEqual(trial, target)
        
        XCTAssertTrue(fence.isClosed())
        
        
            // Test one deliberately reversed
        let fence2 = Perimeter()
        
        fence2.add(noob: liberator!)
        mustang!.reverse()
        fence2.add(noob: mustang!)   // The 'add' routine should reverse this when adding to the array
        fence2.add(noob: fortress!)
        fence2.add(noob: lightning!)
        fence2.add(noob: thunderbolt!)
        
        XCTAssertTrue(fence2.isClosed())
        
        
            // Test all reversed
        let fence3 = Perimeter()
        
        liberator!.reverse()
        fence3.add(noob: liberator!)
        mustang!.reverse()
        fence3.add(noob: mustang!)
        fortress!.reverse()
        fence3.add(noob: fortress!)
        lightning!.reverse()
        fence3.add(noob: lightning!)
        thunderbolt!.reverse()
        fence3.add(noob: thunderbolt!)
        
        XCTAssertTrue(fence3.isClosed())
        
           // Test arbitrary input sequence
        let fence4 = Perimeter()
        
        fence.add(noob: fortress!)
        fence.add(noob: liberator!)
        fence.add(noob: thunderbolt!)
        fence.add(noob: lightning!)
        fence.add(noob: mustang!)
        
        XCTAssert(fence4.isClosed())
        
    }

    // TODO: Add tests for extent, nearEnd, and transform
    
}
