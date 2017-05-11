//
//  OrthoVolTests.swift
//  SketchCurves
//
//  Created by Paul on 11/6/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class OrthoVolTests: XCTestCase {

    func testInit() {    // Needs to have checks added for reversed inputs
        
        let corner1 = Point3D(x: -2.0, y: -2.0, z: -2.0)
        let corner2 = Point3D(x: 3.0, y: 4.0, z: 5.0)
        
        do   {
            
            let shoe = try OrthoVol(corner1: corner1, corner2: corner2)
            
            XCTAssertEqualWithAccuracy (shoe.getWidth(), 5.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (shoe.getHeight(), 6.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (shoe.getDepth(), 7.0, accuracy: Point3D.Epsilon / 3.0)
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }
    
    func testThicken()  {
        
        let corner1 = Point3D(x: -2.0, y: -2.0, z: 0.0)
        let corner2 = Point3D(x: 1.0, y: 2.0, z: 0.0)
        
        do   {
            
            let shoe = try OrthoVol(corner1: corner1, corner2: corner2)
            
            XCTAssertEqualWithAccuracy (shoe.getWidth(), 3.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (shoe.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (shoe.getDepth(), 1.0, accuracy: Point3D.Epsilon / 3.0)
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?  A")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }
    
    func testCombine()  {
        
        let cornerAlpha = Point3D(x: 1.0, y: 1.0, z: 0.0)
        let cornerBeta = Point3D(x: 1.0, y: 5.0, z: 0.0)
        let cornerDelta = Point3D(x: 8.0, y: 1.0, z: 0.0)
        let cornerGamma = Point3D(x: 8.0, y: 5.0, z: 0.0)
        
        do   {
            
            let leftBox = try OrthoVol(corner1: cornerAlpha, corner2: cornerBeta)
            
            XCTAssertEqualWithAccuracy (leftBox.getWidth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (leftBox.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (leftBox.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            
            let rightBox = try OrthoVol(corner1: cornerDelta, corner2: cornerGamma)
            
            XCTAssertEqualWithAccuracy (rightBox.getWidth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (rightBox.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (rightBox.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            
            
            let combi = leftBox + rightBox
            
                // 7.8 because each of the original boxes was thickened by 0.4 on each side
            XCTAssertEqualWithAccuracy (combi.getWidth(), 7.8, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (combi.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
            XCTAssertEqualWithAccuracy (combi.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0)
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?  A2")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }
    
    func testOverlap()   {
        
        let ptAlpha = Point3D(x: 1.0, y: 0.0, z: 1.0)
        let ptBeta = Point3D(x: 1.0, y: 0.0, z: 5.0)
        let ptDelta = Point3D(x: 8.0, y: 0.0, z: 1.0)
        let ptGamma = Point3D(x: 8.0, y: 0.0, z: 5.0)
        
        let lineA = try! LineSeg(end1: ptAlpha, end2: ptBeta)
        
        let lineB = try! LineSeg(end1: ptDelta, end2: ptGamma)

        let flag = OrthoVol.isOverlapping(lhs: lineA.getExtent(), rhs: lineB.getExtent())
        
        XCTAssertFalse(flag)
        
        
        let ptAlpha2 = Point3D(x: 1.0, y: 1.0, z: 1.0)
        let ptBeta2 = Point3D(x: 1.0, y: 5.0, z: 5.0)
        let ptDelta2 = Point3D(x: 1.0, y: 5.0, z: 1.0)
        let ptGamma2 = Point3D(x: 1.0, y: 1.0, z: 5.0)
        
        let lineC = try! LineSeg(end1: ptAlpha2, end2: ptBeta2)
        
        let lineD = try! LineSeg(end1: ptDelta2, end2: ptGamma2)
        
        let flag2 = OrthoVol.isOverlapping(lhs: lineC.getExtent(), rhs: lineD.getExtent())
        
        XCTAssert(flag2)
    }
    
    func testTransform()   {
        
        let sourceVol = OrthoVol(minX: 1.0, maxX: 5.0, minY: -1.2, maxY: 2.8, minZ: 3.0, maxZ: 3.5)
        
        let swing = Transform()
        
        var destVol = sourceVol.transform(xirtam: swing)
        
        XCTAssertEqualWithAccuracy(destVol.getOrigin().x, 1.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(destVol.getOrigin().y, -1.2, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(destVol.getOrigin().z, 3.0, accuracy: Point3D.Epsilon / 3.0)
        
        XCTAssertEqualWithAccuracy(destVol.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(destVol.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0)
        XCTAssertEqualWithAccuracy(destVol.getDepth(), 0.5, accuracy: Point3D.Epsilon / 3.0)
        
           // Test a simple rotation
        let rotX = Transform(rotationAxis: Axis.x, angleRad: Double.pi / 4.0)
        
        /// Handy multiplier
        let sqrt22 = sqrt(2.0) / 2.0
        
        destVol = sourceVol.transform(xirtam: rotX)
        
        XCTAssertEqualWithAccuracy(destVol.getOrigin().x, 1.0, accuracy: Point3D.Epsilon / 3.0)
        
        let targetY = sourceVol.getOrigin().y * sqrt22 - (sourceVol.getOrigin().z + sourceVol.getDepth()) * sqrt22
        XCTAssertEqualWithAccuracy(destVol.getOrigin().y, targetY, accuracy: Point3D.Epsilon / 3.0)
        
        let targetZ = (sourceVol.getOrigin().z) * sqrt22 + sourceVol.getOrigin().y * sqrt22
        XCTAssertEqualWithAccuracy(destVol.getOrigin().z, targetZ, accuracy: Point3D.Epsilon / 3.0)
        

        XCTAssertEqualWithAccuracy(destVol.getWidth(), 4.0, accuracy: Point3D.Epsilon / 3.0)

        let targetHeight = (sourceVol.getHeight() + sourceVol.getDepth()) * sqrt22
        XCTAssertEqualWithAccuracy(destVol.getHeight(), targetHeight, accuracy: Point3D.Epsilon / 3.0)
        
        let targetDepth = (sourceVol.getDepth() + sourceVol.getHeight()) * sqrt22
        XCTAssertEqualWithAccuracy(destVol.getDepth(), targetDepth, accuracy: Point3D.Epsilon / 3.0)
                
    }

}
