//
//  LineSegTests.swift
//  SketchCurves
//
//  Created by Paul on 11/3/15.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class LineSegTests: XCTestCase {

    
    func testFidelity()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        XCTAssert(alpha == stroke.getOneEnd())
        XCTAssert(beta == stroke.getOtherEnd())
        
        XCTAssert(stroke.usage == PenTypes.ordinary)
        
        let gamma = Point3D(x: 2.5, y: 2.5, z: 2.5)
        
        XCTAssertThrowsError(try LineSeg(end1: alpha, end2: gamma))
        
    }
    
    func testSetIntent()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        XCTAssert(stroke.usage == PenTypes.ordinary)
        
        stroke.setIntent(purpose: PenTypes.ideal)
        XCTAssert(stroke.usage == PenTypes.ideal)
        
    }
    


    /// Test a point at some proportion along the line segment
    func testPointAt() {
        
        let pt1 = Point3D(x: 1.0, y: 1.0, z: 1.0)
        let pt2 = Point3D(x: 5.0, y: 5.0, z: 5.0)
        
        let slash = try! LineSeg(end1: pt1, end2: pt2)
        
        let ladybug = try! slash.pointAt(t: 0.6)
        
        let home = Point3D(x: 3.4, y: 3.4, z: 3.4)
        
        XCTAssert(ladybug == home)
        
    }
    

    func testTangent()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 2.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let target = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let trial = stroke.tangentAt(t: 0.5)
        
        XCTAssert(trial == target)
        
    }
    
    func testLength()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let bar = try! LineSeg(end1: alpha, end2: beta)
        
        let target = 2.0
        
        XCTAssertEqual(bar.getLength(), target)
    }
    

    func testReverse()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 4.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        stroke.reverse()
        
        XCTAssertEqual(alpha, stroke.getOtherEnd())
        XCTAssertEqual(beta, stroke.getOneEnd())
    }
    
    func testChangeEnd()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 2.5, y: 4.5, z: 3.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let shifted1 = Point3D(x: 2.5, y: 5.0, z: 3.5)
        
        try! stroke.changeEnd(newLoc: shifted1, head: false)
        
        XCTAssert(stroke.getOtherEnd() == shifted1)
        
        
        let shifted2 = Point3D(x: 2.5, y: 2.7, z: 3.0)
        
        try! stroke.changeEnd(newLoc: shifted2, head: true)
        
        XCTAssert(stroke.getOneEnd() == shifted2)
        
           // Attempt coincident points
        XCTAssertThrowsError(try stroke.changeEnd(newLoc: shifted2, head: false))
        
        XCTAssertThrowsError(try stroke.changeEnd(newLoc: shifted1, head: true))
        
    }
    
    func testResolveRelative()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let pip = Point3D(x: 3.5, y: 3.0, z: 2.5)
        
        let offset = stroke.resolveRelative(speck: pip)
        
        
        let targetA = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        let targetP = Vector3D(i: 0.0, j: 0.5, k: 0.0)
        
        XCTAssertEqual(offset.along, targetA)
        XCTAssertEqual(offset.perp, targetP)
        
    }
    
    func testTransform()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 2.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let swing = Transform(rotationAxis: Axis.z, angleRad: Double.pi / 2.0)
        
        let door = try! stroke.transform(xirtam: swing)
        
        let targetAlpha = Point3D(x: -2.5, y: 2.5, z: 2.5)
        let targetBeta = Point3D(x: -2.5, y: 4.5, z: 2.5)
        
        XCTAssert(door.getOneEnd() == targetAlpha)
        XCTAssert(door.getOtherEnd() == targetBeta)

    }
    
    func testIsCrossing()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 2.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let chopA = Point3D(x: 2.4, y: 2.8, z: 2.5)
        let chopB = Point3D(x: 2.6, y: 2.7, z: 2.5)
        
        let chop = try! LineSeg(end1: chopA, end2: chopB)
        
        let flag1 = stroke.isCrossing(chop: chop)
        
        XCTAssert(flag1)
        
    }
    
    func testClipTo()   {
        
        let alpha = Point3D(x: 2.5, y: 2.5, z: 2.5)
        let beta = Point3D(x: 4.5, y: 4.5, z: 2.5)
        
        let stroke = try! LineSeg(end1: alpha, end2: beta)
        
        let cliff = Point3D(x: 4.0, y: 4.0, z: 2.5)
        
        let shorter = stroke.clipTo(stub: cliff, keepNear: true)
        
        let target = 1.5 * sqrt(2.0)
        
        XCTAssertEqual(target, shorter.getLength(), accuracy: Point3D.Epsilon)
        
        let distal = stroke.clipTo(stub: cliff, keepNear: false)
        let target2 = 0.5 * sqrt(2.0)
        
        XCTAssertEqual(target2, distal.getLength(), accuracy: Point3D.Epsilon)
        
    }
    
    func testIntersectLine()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let plateau = try! LineSeg(end1: ptA, end2: ptB)   // Known benign points
        
        var launcher = Point3D(x: 3.0, y: -1.0, z: 5.0)
        var azimuth = Vector3D(i: 0.0, j: -1.0, k: 0.0)
        
        var shot = try! Line(spot: launcher, arrow: azimuth)
        
        let target = Point3D(x: 3.0, y: 3.0, z: 5.0)
        
        let crater = plateau.intersect(ray: shot)
        
        XCTAssert(crater.count == 1)
        XCTAssertEqual(crater.first!, target)
        
           // Case of being outside the range of the segment
        launcher = Point3D(x: 1.0, y: -1.0, z: 5.0)
        shot = try! Line(spot: launcher, arrow: azimuth)
        
        let crater2 = plateau.intersect(ray: shot)
   
        XCTAssert(crater2.isEmpty)
        

            // Also outside the range of the segment
        launcher = Point3D(x: 1.0, y: -3.0, z: 5.0)
        azimuth = Vector3D(i: -0.5, j: 0.866, k: 0.0)
        shot = try! Line(spot: launcher, arrow: azimuth)
        
        let crater3 = plateau.intersect(ray: shot)
        
        XCTAssert(crater3.isEmpty)
        
           // Parallel case
        let ptC = Point3D(x: 3.0, y: 2.0, z: 5.0)
        let ptD = Point3D(x: 1.0, y: 4.0, z: 5.0)
        
        var dir = Vector3D.built(from: ptC, towards: ptD, unit: true)
        let cliff = try! Line(spot: ptC, arrow: dir)
        
        let crater4 = plateau.intersect(ray: cliff)

        XCTAssert(crater4.isEmpty)
        
           // Coincident case
        let ptE = Point3D(x: 5.0, y: 1.0, z: 5.0)
        let ptF = Point3D(x: 1.0, y: 5.0, z: 5.0)
        
        dir = Vector3D.built(from: ptE, towards: ptF, unit: true)
        let cliff2 = try! Line(spot: ptE, arrow: dir)

        let crater5 = plateau.intersect(ray: cliff2)
        
        XCTAssert(crater5.count == 2)
        
    }
    
    func testInsetLine()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let plateau = try! LineSeg(end1: ptA, end2: ptB)   // Known benign points
        
        let rocket = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        let buddy = plateau.insetLine(inset: 1.0, stbdIn: true, upward: rocket)
        
        let diffs = buddy.resolveRelative(yonder: plateau.getOneEnd())
        
        XCTAssertEqual(diffs.perp, 1.0, accuracy: Point3D.Epsilon)
        
        let stretched = try! Line(spot: plateau.getOneEnd(), arrow: plateau.getDirection())
        
        XCTAssert(Line.isParallel(straightA: buddy, straightB: stretched))
        
        
        
           // Check the other side
        let wingman = plateau.insetLine(inset: 1.0, stbdIn: false, upward: rocket)
        
        let diffs2 = buddy.resolveRelative(yonder: wingman.getOrigin())
        
        XCTAssertEqual(diffs2.perp, 2.0, accuracy: Point3D.Epsilon)
        
        XCTAssert(Line.isParallel(straightA: wingman, straightB: stretched))

    }
    
    func testCrown()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let plateau = try! LineSeg(end1: ptA, end2: ptB)
        
        XCTAssert(plateau.findCrown(smallerT: 0.0, largerT: 1.0)  == 0.0)
        
    }
    
    func testFindStep()   {
        
        let ptA = Point3D(x: 4.0, y: 2.0, z: 5.0)
        let ptB = Point3D(x: 2.0, y: 4.0, z: 5.0)
        
        let dash = try! LineSeg(end1: ptA, end2: ptB)
        
        let param = 0.6
        
        let inc = dash.findStep(allowableCrown: 0.010, currentT: param, increasing: true)
        XCTAssert(inc == 1.0)
        
        let dec = dash.findStep(allowableCrown: 0.010, currentT: param, increasing: false)
        XCTAssert(dec == 0.0)
        
    }
    
}
