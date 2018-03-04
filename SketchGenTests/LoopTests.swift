//
//  LoopTests.swift
//  LineSegShowTests
//
//  Created by Paul on 2/4/18.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.
//

import XCTest

class LoopTests: XCTestCase {
    
    var simple: CoordinateSystem?
    
    override func setUp() {
        super.setUp()
        
        let orig = Point3D(x: 0.0, y: 0.0, z: 0.0)
        let h = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let v = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        simple = try! CoordinateSystem(spot: orig, alpha: h, beta: v, gamma: up)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCount()   {
        
        let ptA = Point3D(x: -1.0, y: 4.0, z: 0.0)
        let ptB = Point3D(x: 4.5, y: 3.5, z: 0.0)
        let ptC = Point3D(x: 5.0, y: 0.7, z: 0.0)
        let ptD = Point3D(x: -1.0, y: 0.5, z: 0.0)
        
        let side1 = try! LineSeg(end1: ptA, end2: ptB)
        let side2 = try! LineSeg(end1: ptB, end2: ptC)
        let side3 = try! LineSeg(end1: ptC, end2: ptD)
        let side4 = try! LineSeg(end1: ptD, end2: ptA)
        
        let lasso = Loop(refCoord: simple!)
        
        lasso.add(noob: side1)
        lasso.add(noob: side2)
        lasso.add(noob: side3)
        lasso.add(noob: side4)
        
        let population = lasso.pieces.count
        
        XCTAssert(population == 4)
        
    }
    
    
    func testAdd()   {
        
        let ptA = Point3D(x: -2.0, y: 8.0, z: 0.0)
        let ptB = Point3D(x: 2.0, y: 8.0, z: 0.0)
        let ptC = Point3D(x: 2.0, y: 6.0, z: 0.0)
        let ptD = Point3D(x: 6.0, y: 6.0, z: 0.0)
        let ptE = Point3D(x: 9.0, y: 7.0, z: 0.0)
        let ptF = Point3D(x: 7.0, y: 2.0, z: 0.0)
        let ptG = Point3D(x: 2.0, y: 2.0, z: 0.0)
        let ptH = Point3D(x: 0.0, y: 4.0, z: 0.0)
        let ptI = Point3D(x: 0.0, y: 7.0, z: 0.0)
        let ptJ = Point3D(x: -2.0, y: 7.0, z: 0.0)
        
        let side0 = try! LineSeg(end1: ptA, end2: ptB)
        let side1 = try! LineSeg(end1: ptB, end2: ptC)
        let side2 = try! LineSeg(end1: ptC, end2: ptD)
        let side3 = try! LineSeg(end1: ptD, end2: ptE)
        let side4 = try! LineSeg(end1: ptE, end2: ptF)
        let side5 = try! LineSeg(end1: ptF, end2: ptG)
        let side6 = try! LineSeg(end1: ptG, end2: ptH)
        let side7 = try! LineSeg(end1: ptH, end2: ptI)
        let side8 = try! LineSeg(end1: ptI, end2: ptJ)
        let side9 = try! LineSeg(end1: ptJ, end2: ptA)
        
        
        
        /// The Loop for proving a number of abilities
        let mallard = Loop(refCoord: simple!)
        
        mallard.add(noob: side4)
        
        XCTAssert(mallard.pieces.count == 1)
        XCTAssert(mallard.bucket.count == 2)
        
        
        mallard.add(noob: side2)
        
        XCTAssert(mallard.pieces.count == 2)
        XCTAssert(mallard.bucket.count == 4)
        
        
        mallard.add(noob: side5)
        
        // Find the unmated members of bucket
        var bachelors = mallard.bucket.filter { $0.other == nil }
        
        XCTAssert(mallard.pieces.count == 3)
        XCTAssert(mallard.bucket.count == 5)
        XCTAssert(bachelors.count == 4)
        
        XCTAssertFalse(mallard.isClosed)
        
        
        mallard.add(noob: side3)
        
        // Find the unmated members of bucket
        bachelors = mallard.bucket.filter { $0.other == nil }
        
        XCTAssert(mallard.pieces.count == 4)
        XCTAssert(mallard.bucket.count == 5)
        XCTAssert(bachelors.count == 2)
        
        
        // How do you check for duplicate curves?
        mallard.add(noob: side8)
        mallard.add(noob: side9)
        mallard.add(noob: side0)
        
        XCTAssert(mallard.pieces.count == 7)
        XCTAssert(mallard.bucket.count == 9)
        
        bachelors = mallard.bucket.filter { $0.other == nil }
        XCTAssert(bachelors.count == 4)
        
        
        mallard.add(noob: side1)
        mallard.add(noob: side6)
        
        XCTAssert(mallard.pieces.count == 9)
        XCTAssert(mallard.bucket.count == 10)
        
        
        bachelors = mallard.bucket.filter { $0.other == nil }
        XCTAssert(bachelors.count == 2)
        
        XCTAssertFalse(mallard.isClosed)
        
        
        // Close out the Loop
        mallard.add(noob: side7)
        
        XCTAssert(mallard.pieces.count == 10)
        XCTAssert(mallard.bucket.count == 10)
        
        
        bachelors = mallard.bucket.filter { $0.other == nil }
        XCTAssert(bachelors.count == 0)
        
        XCTAssert(mallard.isClosed)
        
    }
    
    
    
    func testAlign()   {
        
        let ptA = Point3D(x: -2.0, y: 8.0, z: 0.0)
        let ptB = Point3D(x: 2.0, y: 8.0, z: 0.0)
        let ptC = Point3D(x: 2.0, y: 6.0, z: 0.0)
        let ptD = Point3D(x: 6.0, y: 6.0, z: 0.0)
        let ptE = Point3D(x: 9.0, y: 7.0, z: 0.0)
        let ptF = Point3D(x: 7.0, y: 2.0, z: 0.0)
        let ptG = Point3D(x: 2.0, y: 2.0, z: 0.0)
        let ptH = Point3D(x: 0.0, y: 4.0, z: 0.0)
        let ptI = Point3D(x: 0.0, y: 7.0, z: 0.0)
        let ptJ = Point3D(x: -2.0, y: 7.0, z: 0.0)
        
        let side0 = try! LineSeg(end1: ptB, end2: ptA)
        let side1 = try! LineSeg(end1: ptB, end2: ptC)
        let side2 = try! LineSeg(end1: ptC, end2: ptD)
        let side3 = try! LineSeg(end1: ptD, end2: ptE)
        let side4 = try! LineSeg(end1: ptF, end2: ptE)
        let side5 = try! LineSeg(end1: ptF, end2: ptG)
        let side6 = try! LineSeg(end1: ptH, end2: ptG)
        let side7 = try! LineSeg(end1: ptH, end2: ptI)
        let side8 = try! LineSeg(end1: ptI, end2: ptJ)
        let side9 = try! LineSeg(end1: ptJ, end2: ptA)
        
        
        
        /// The Loop for proving a number of abilities
        let mallard = Loop(refCoord: simple!)
        
        mallard.add(noob: side4)
        mallard.add(noob: side0)
        mallard.add(noob: side3)
        mallard.add(noob: side9)
        mallard.add(noob: side7)
        mallard.add(noob: side1)
        mallard.add(noob: side2)
        mallard.add(noob: side6)
        mallard.add(noob: side5)
        mallard.add(noob: side8)
        
        XCTAssert(mallard.isClosed)
        
        XCTAssert(mallard.ordered.isEmpty)
        
        mallard.align()
        
        XCTAssert(mallard.ordered.count == 10)
        
        
        // Should all of this be tested in a different sketching plane?
    }
    
    
    func testIsJoined()   {
        
        let ptA = Point3D(x: -1.0, y: 4.0, z: 0.0)
        let ptB = Point3D(x: 4.5, y: 3.5, z: 0.0)
        let ptC = Point3D(x: 5.0, y: 0.7, z: 0.0)
        let ptD = Point3D(x: -1.0, y: 0.5, z: 0.0)
        
        let side0 = try! LineSeg(end1: ptA, end2: ptB)
        let side1 = try! LineSeg(end1: ptB, end2: ptC)
        //       let side2 = try! LineSeg(end1: ptC, end2: ptD)
        let side3 = try! LineSeg(end1: ptD, end2: ptA)
        
        let lasso = Loop(refCoord: simple!)
        
        lasso.add(noob: side0)
        lasso.add(noob: side1)
        lasso.add(noob: side3)
        
        let join0 = lasso.isjoined(xedni: 0)
        
        XCTAssert(join0)
        
        
        let join1 = lasso.isjoined(xedni: 1)
        
        XCTAssertFalse(join1)
        
    }
    
    func testIsClosed()   {
        
        let ptA = Point3D(x: -1.0, y: 4.0, z: 0.0)
        let ptB = Point3D(x: 4.5, y: 3.5, z: 0.0)
        let ptC = Point3D(x: 5.0, y: 0.7, z: 0.0)
        let ptD = Point3D(x: -1.0, y: 0.5, z: 0.0)
        
        let side0 = try! LineSeg(end1: ptA, end2: ptB)
        let side1 = try! LineSeg(end1: ptB, end2: ptC)
        let side2 = try! LineSeg(end1: ptC, end2: ptD)
        let side3 = try! LineSeg(end1: ptD, end2: ptA)
        
        let lasso = Loop(refCoord: simple!)
        
        lasso.add(noob: side0)
        lasso.add(noob: side1)
        lasso.add(noob: side2)
        lasso.add(noob: side3)
        
        XCTAssert(lasso.checkIsClosed())
        
        
        
        // Leave out one side
        let lasso2 = Loop(refCoord: simple!)
        
        lasso2.add(noob: side0)
        lasso2.add(noob: side1)
        // lasso.add(noob: side2)
        lasso2.add(noob: side3)
        
        XCTAssertFalse(lasso2.checkIsClosed())
        
        
        // The case of a full circle
        let center = Point3D(x: 0.5, y: 0.75, z: 0.0)
        let drill = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let trats = Point3D(x: 0.5, y: 1.00, z: 0.0)
        
        let calcutta = try! Arc(center: center, axis: drill, end1: trats, sweep: Double.pi * 2.0)
        
        let lasso3 = Loop(refCoord: simple!)
        lasso3.add(noob: calcutta)
        
        XCTAssert(lasso3.checkIsClosed())
        
        
        // Not a complete circle
        let crescentCity = try! Arc(center: center, axis: drill, end1: trats, sweep: Double.pi)
        
        let lasso4 = Loop(refCoord: simple!)
        lasso4.add(noob: crescentCity)
        
        XCTAssertFalse(lasso4.checkIsClosed())
        
    }
    
    
}

