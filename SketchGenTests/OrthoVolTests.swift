//
//  OrthoVolTests.swift
//  CurveLab
//
//  Created by Paul on 11/6/15.
//  
//

import XCTest

class OrthoVolTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        
        let corner1 = Point3D(x: -2.0, y: -2.0, z: -2.0)
        let corner2 = Point3D(x: 3.0, y: 4.0, z: 5.0)
        
        do   {
            
            let shoe = try OrthoVol(corner1: corner1, corner2: corner2)
            
            XCTAssertEqualWithAccuracy (shoe.getWidth(), 5.0, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (shoe.getHeight(), 6.0, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (shoe.getDepth(), 7.0, accuracy: Point3D.Epsilon / 3.0, "");
            
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
            
            XCTAssertEqualWithAccuracy (shoe.getWidth(), 3.0, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (shoe.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (shoe.getDepth(), 1.0, accuracy: Point3D.Epsilon / 3.0, "");
            
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
            
            XCTAssertEqualWithAccuracy (leftBox.getWidth(), 0.8, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (leftBox.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (leftBox.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0, "");
            
            let rightBox = try OrthoVol(corner1: cornerDelta, corner2: cornerGamma)
            
            XCTAssertEqualWithAccuracy (rightBox.getWidth(), 0.8, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (rightBox.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (rightBox.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0, "");
            
            let combi = leftBox + rightBox
            
                // 7.8 because each of the original boxes was thickened by 0.4 on each side
            XCTAssertEqualWithAccuracy (combi.getWidth(), 7.8, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (combi.getHeight(), 4.0, accuracy: Point3D.Epsilon / 3.0, "");
            XCTAssertEqualWithAccuracy (combi.getDepth(), 0.8, accuracy: Point3D.Epsilon / 3.0, "");
            
        } catch is CoincidentPointsError  {
            print("Really?  You screwed up in a unit test?  A2")
        }  catch  {
            print("Some other logic screw-up while testing a box")
        }
    }

}
