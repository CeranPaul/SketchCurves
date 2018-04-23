//
//  CubicTests.swift
//  SketchCurves
//
//  Created by Paul on 7/16/16.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class CubicTests: XCTestCase {

    var cup: Cubic?
    
    override func setUp() {
        super.setUp()
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        cup = Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
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
        
        XCTAssert(flag1)
        
        let otherTrial = bump.pointAt(t: 1.0)
        let flag2 = Point3D.dist(pt1: otherTrial, pt2: beta) < (Point3D.Epsilon / 3.0)
        
        XCTAssert(flag2)

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
    
    func testGetters()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let control1 = alpha.offset(jump: alSlope)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        let bReverse = betSlope.reverse()
        let control2 = beta.offset(jump: bReverse)
        
        let bump = Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        
        let retAlpha = bump.getOneEnd()
        XCTAssertEqual(alpha, retAlpha)
        
        let retBeta = bump.getOtherEnd()
        XCTAssertEqual(beta, retBeta)
        
    }
    
    func testSetIntent()   {
        
        XCTAssert(cup!.usage == PenTypes.ordinary)
        
        cup!.setIntent(purpose: PenTypes.ideal)
        XCTAssert(cup!.usage == PenTypes.ideal)
        
    }
    

    func testSumsHermite()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        let bump = Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
        let sumX = bump.ax + bump.bx + bump.cx + bump.dx
        let sumY = bump.ay + bump.by + bump.cy + bump.dy
        let sumZ = bump.az + bump.bz + bump.cz + bump.dz
        
        XCTAssertEqual(beta.x, sumX, accuracy: 0.0001)
        XCTAssertEqual(beta.y, sumY, accuracy: 0.0001)
        XCTAssertEqual(beta.z, sumZ, accuracy: 0.0001)
    }
    
    func testSumsBezier()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let control1 = alpha.offset(jump: alSlope)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        let bReverse = betSlope.reverse()
        let control2 = beta.offset(jump: bReverse)
        
        let bump = Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        let sumX = bump.ax + bump.bx + bump.cx + bump.dx
        let sumY = bump.ay + bump.by + bump.cy + bump.dy
        let sumZ = bump.az + bump.bz + bump.cz + bump.dz
        
        XCTAssertEqual(beta.x, sumX, accuracy: 0.0001)
        XCTAssertEqual(beta.y, sumY, accuracy: 0.0001)
        XCTAssertEqual(beta.z, sumZ, accuracy: 0.0001)
    }
    
    func testExtent()   {
        
        let alpha = Point3D(x: -2.3, y: 1.5, z: 0.7)
        
        let control1 = Point3D(x: -3.1, y: 0.0, z: 0.7)
        
        let control2 = Point3D(x: -3.1, y: -1.6, z: 0.7)
        
        let beta = Point3D(x: -2.7, y: -3.4, z: 0.7)
        
        let bump = Cubic(ptA: alpha, controlA: control1, controlB: control2, ptB: beta)
        
        
        let box = bump.getExtent()
        
        XCTAssertEqual(box.getOrigin().x, -2.9624, accuracy: 0.0001)
    }
    
    func testTransform()   {
        
        let fling = Transform(rotationAxis: Axis.z, angleRad: Double.pi / 4.0)
        
        let alpha = cup!.getOneEnd()
        let freshAlpha = Point3D.transform(pip: alpha, xirtam: fling)
        
        let omega = cup!.getOtherEnd()
        let freshOmega = Point3D.transform(pip: omega, xirtam: fling)
        
        let mid = cup!.pointAt(t: 0.35)
        let freshMid = Point3D.transform(pip: mid, xirtam: fling)
        
        let bulge = cup!.transform(xirtam: fling) as! Cubic   // Because the return value is a PenCurve
        
        XCTAssert(freshAlpha == bulge.getOneEnd())
        XCTAssert(freshOmega == bulge.getOtherEnd())
        
        let target = bulge.pointAt(t: 0.35)
        XCTAssert(freshMid == target)
    }
    
    
    /// I don't know if I can always expect this to work.
    func testReverse()   {
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        /// Reversed the parameters
        let scoop = Cubic(ptA: beta, slopeA: betSlope.reverse(), ptB: alpha, slopeB: alSlope.reverse())
        
        let midA = scoop.pointAt(t: 0.10)
        let midB = scoop.pointAt(t: 0.75)
        
        
        XCTAssert(cup?.pointAt(t: 0.90) == midA)
        XCTAssert(cup?.pointAt(t: 0.25) == midB)
        
    }
    
    func testRefine()   {
        
        let near = Point3D(x: 2.9, y: 1.4, z: 0.7)
        
        let startRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        let narrower = cup!.refineRangeDist(speck: near, span: startRange)
        
        XCTAssert(narrower?.lowerBound == 0.8)
        XCTAssert(narrower?.upperBound == 1.0)
        
        let narrower3 = cup!.refineRangeDist(speck: near, span: narrower!)
        
        XCTAssert(narrower3?.lowerBound == 0.86)
        XCTAssert(narrower3?.upperBound == 0.90)
        

        let near2 = Point3D(x: 2.65, y: 1.45, z: 0.7)
        
        let narrower2 = cup!.refineRangeDist(speck: near2, span: startRange)
        
        XCTAssert(narrower2?.lowerBound == 0.2)
        XCTAssert(narrower2?.upperBound == 0.4)
        

        let near3 = Point3D(x: 2.40, y: 1.45, z: 0.7)
        
        let narrower4 = cup!.refineRangeDist(speck: near3, span: startRange)
        
        XCTAssert(narrower4?.lowerBound == 0.0)
        XCTAssert(narrower4?.upperBound == 0.2)
        
        
    }
    
    
    func testFindCrown()   {
        
        let hump = cup!.findCrown(smallerT: 0.20, largerT: 0.85)
        
        XCTAssertEqual(hump, 0.0541, accuracy: 0.0001)
    }
    
    func testFindClosest()   {
        
        let near = Point3D(x: 2.9, y: 1.4, z: 0.7)
        
        let buddy = cup!.findClosest(speck: near).pip
        
        let target = Point3D(x: 2.99392, y: 1.65063, z: 0.70000)
        
        XCTAssertEqual(buddy, target)
    }
    
    
    /// Basic intersection tests in the XY plane
    func testIntLine1()   {
        
        let ptA = Point3D(x: 1.80, y: 1.40, z: 0.0)
        let ptB = Point3D(x: 2.10, y: 1.95, z: 0.0)
        let ptC = Point3D(x: 2.70, y: 2.30, z: 0.0)
        let ptD = Point3D(x: 3.50, y: 2.05, z: 0.0)
        
        let target = Cubic(alpha: ptA, beta: ptB, betaFraction: 0.35, gamma: ptC, gammaFraction: 0.70, delta: ptD)
        
        let ptE = Point3D(x: 2.50, y: 1.30, z: 0.0)
        let ptF = Point3D(x: 3.35, y: 2.20, z: 0.0)
        
        /// Line segment to test for intersection
        let arrow1 = try! LineSeg(end1: ptE, end2: ptF)
        
        /// Line made from the LineSeg
        let ray = try! Line(spot: arrow1.getOneEnd(), arrow: arrow1.getDirection())
        
        
        let spots = target.intersect(ray: ray, accuracy: 0.001)
        
        let tnuoc = spots.count
        XCTAssertEqual(tnuoc, 1)
        
        let common = spots.first!
        XCTAssertEqual(common.x, 3.312, accuracy: 0.001)
        XCTAssertEqual(common.y, 2.161, accuracy: 0.001)
        XCTAssertEqual(common.z, 0.0, accuracy: 0.001)
    }
    
    
    func testIntLine2()   {
        
        let ax = 0.016
        let bx = -0.108
        let cx = -0.174
        let dx = 0.571
        let ay = -0.023
        let by = 0.180
        let cy = -0.291
        let dy = 0.119
        let az = 0.0
        let bz = 0.0
        let cz = 0.0
        let dz = 0.0
        
        let bowl = Cubic(ax: ax, bx: bx, cx: cx, dx: dx, ay: ay, by: by, cy: cy, dy: dy, az: az, bz: bz, cz: cz, dz: dz)
        
                
        let ptA = Point3D(x: 0.02, y: 0.25, z: 0.0)
        let ptB = Point3D(x: 0.59, y: 0.25, z: 0.0)
        
        let horizon1 = try!  LineSeg(end1: ptA, end2: ptB)
        
        let ray1 = try! Line(spot: ptA, arrow: horizon1.getDirection())
        
        let ptC = Point3D(x: 0.02, y: 0.065, z: 0.0)
        let ptD = Point3D(x: 0.59, y: 0.065, z: 0.0)
        
        let horizon2 = try!  LineSeg(end1: ptC, end2: ptD)
        
        let ray2 = try! Line(spot: ptC, arrow: horizon2.getDirection())
        
        
        var pots = bowl.intersect(ray: ray1, accuracy: Point3D.Epsilon)
        XCTAssert(pots.isEmpty)
        
        pots = bowl.intersect(ray: ray2, accuracy: Point3D.Epsilon)
        XCTAssertFalse(pots.isEmpty)
        
    }
    
    
}
