//
//  LineTests.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 12/10/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
//

import XCTest

class LineTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /// Verify the fidelity of recording the inputs
    func testFidelity()  {
        
        let nexus = Point3D(x: -2.5, y: 1.5, z: 0.015)
        var horn = Vector3D(i: 12.0, j: 3.0, k: 4.0)
        horn.normalize()
        
        do   {
            
            let contrail = try Line(spot: nexus, arrow: horn)
            
            XCTAssert(contrail.origin.x == -2.5)
            XCTAssert(contrail.origin.y == 1.5)
            XCTAssert(contrail.origin.z == 0.015)
            
            XCTAssert(contrail.direction.i == 12.0 / 13.0)
            XCTAssert(contrail.direction.j == 3.0 / 13.0)
            XCTAssert(contrail.direction.k == 4.0 / 13.0)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Line")
        }
    }
    

}
