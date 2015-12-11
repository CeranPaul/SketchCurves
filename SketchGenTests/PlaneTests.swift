//
//  PlaneTests.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 12/10/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
//

import XCTest

class PlaneTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Verify the correctness of recording the inputs
    func testFidelity()  {
        
        let nexus = Point3D(x: 2.0, y: 3.0, z: 4.0)
        var horn = Vector3D(i: 3.0, j: 4.0, k: 12.0)
        horn.normalize()
        
        do   {
            
            let llanoEstacado = try Plane(spot: nexus, arrow: horn)
        
            XCTAssert(llanoEstacado.location.x == 2.0)
            XCTAssert(llanoEstacado.location.y == 3.0)
            XCTAssert(llanoEstacado.location.z == 4.0)

            XCTAssert(llanoEstacado.normal.i == 3.0 / 13.0)
            XCTAssert(llanoEstacado.normal.j == 4.0 / 13.0)
            XCTAssert(llanoEstacado.normal.k == 12.0 / 13.0)
            
        }   catch   {
            print("Did you really throw an error in a test case?  Plane")
        }
    }
    
}
