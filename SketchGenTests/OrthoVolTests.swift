//
//  OrthoVolTests.swift
//  SketchCurves
//
//  Created by Paul on 11/6/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class OrthoVolTests: XCTestCase {

    func testInit() {
        
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

        let flag = OrthoVol.isOverlapping(lhs: lineA.extent, rhs: lineB.extent)
        
        XCTAssertFalse(flag)
        
        
        let ptAlpha2 = Point3D(x: 1.0, y: 1.0, z: 1.0)
        let ptBeta2 = Point3D(x: 1.0, y: 5.0, z: 5.0)
        let ptDelta2 = Point3D(x: 1.0, y: 5.0, z: 1.0)
        let ptGamma2 = Point3D(x: 1.0, y: 1.0, z: 5.0)
        
        let lineC = try! LineSeg(end1: ptAlpha2, end2: ptBeta2)
        
        let lineD = try! LineSeg(end1: ptDelta2, end2: ptGamma2)
        
        let flag2 = OrthoVol.isOverlapping(lhs: lineC.extent, rhs: lineD.extent)
        
        XCTAssert(flag2)
    }

}
