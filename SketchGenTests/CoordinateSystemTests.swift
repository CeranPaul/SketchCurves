//
//  CoordinateSystemTests.swift
//  SketchCurves
//
//  Created by Paul on 4/26/17.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import XCTest

class CoordinateSystemTests: XCTestCase {
    
    func testFidelity1()   {
        
        let prong = CoordinateSystem()
        
        let targetOrig = Point3D(x: 0.0, y: 0.0, z: 0.0)
        
        XCTAssert(prong.getOrigin() == targetOrig)
        
        
        var targetVec = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        XCTAssert(prong.getAxisX() == targetVec)
        
        
        targetVec = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        XCTAssert(prong.getAxisY() == targetVec)
        
        
        targetVec = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        XCTAssert(prong.getAxisZ() == targetVec)
        
    }
    
    func testIsMutOrtho()   {
        
        let sqrt22 = sqrt(2.0) / 2.0
        
        var axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        var axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        var axis3 = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        XCTAssert(CoordinateSystem.isMutOrtho(uno: axis1, dos: axis2, tres: axis3))
        
        
        axis1 = Vector3D(i: 1.0, j: 0.0, k: 0.0)

        XCTAssertFalse(CoordinateSystem.isMutOrtho(uno: axis1, dos: axis2, tres: axis3))
        
        
        axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        axis2 = Vector3D(i: 0.0, j: -1.0, k: 0.0)

        XCTAssertFalse(CoordinateSystem.isMutOrtho(uno: axis1, dos: axis2, tres: axis3))
        
        
        axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        axis3 = Vector3D(i: sqrt(3.0) / 2.0, j: 0.5, k: 0.0)
        
        XCTAssertFalse(CoordinateSystem.isMutOrtho(uno: axis1, dos: axis2, tres: axis3))
        
    }
    
    
    func testFidelity2() {
        
        let home = Point3D(x: 5.0, y: 2.0, z: 1.0)
        
        let sqrt22 = sqrt(2.0) / 2.0
        
        var axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        var axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        var axis3 = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let rotZ = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        
        let targetOrig = Point3D(x: 5.0, y: 2.0, z: 1.0)
        
        XCTAssert(rotZ.getOrigin() == targetOrig)
        
        
        XCTAssert(rotZ.getAxisX() == axis1)
        XCTAssert(rotZ.getAxisY() == axis2)
        XCTAssert(rotZ.getAxisZ() == axis3)
        
        
        axis1 = Vector3D(i: sqrt22, j: 0.0, k: 0.0)
        
        XCTAssertThrowsError(try CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3))

        
        axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        axis2 = Vector3D(i: 0.0, j: sqrt22, k: 0.0)
        
        XCTAssertThrowsError(try CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3))
        
        
        axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        axis3 = Vector3D(i: 0.0, j: 0.0, k: 0.1)
        
        XCTAssertThrowsError(try CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3))
        
        
        axis3 = Vector3D(i: sqrt22, j: 0.0, k: sqrt22)
        
        XCTAssertThrowsError(try CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3))
        
    }
    
    
    func testFidelity3()   {
        
        let home = Point3D(x: 5.0, y: 2.0, z: 1.0)
        
        let sqrt22 = sqrt(2.0) / 2.0
        
        let vec1 = Vector3D(i: 0.0, j: 0.0, k: -1.0)
        
        let vec2 = Vector3D(i: 0.0, j: sqrt22, k: -sqrt22)
        
        let side = try! CoordinateSystem(spot: home, direction1: vec1, direction2: vec2, useFirst: true, verticalRef: false)
        
        let targetOut = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        XCTAssert(side.getAxisZ() == targetOut)
        
        
        let vec3 = Vector3D(i: 0.0, j: 0.0, k: 0.4)
        
        XCTAssertThrowsError(try CoordinateSystem(spot: home, direction1: vec3, direction2: vec2, useFirst: true, verticalRef: false))
        
        
        let vec4 = Vector3D(i: 0.0, j: 0.4, k: 0.0)
        
        XCTAssertThrowsError(try CoordinateSystem(spot: home, direction1: vec2, direction2: vec4, useFirst: true, verticalRef: false))
        
        
            // This error should get thrown by the CrossProduct
        let vec5 = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        XCTAssertThrowsError(try CoordinateSystem(spot: home, direction1: vec1, direction2: vec5, useFirst: true, verticalRef: false))
        
        
        let vec6 = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        let rotSide = try! CoordinateSystem(spot: home, direction1: vec2, direction2: vec6, useFirst: true, verticalRef: false)
        
        XCTAssert(rotSide.getAxisZ() == targetOut)
        XCTAssert(rotSide.getAxisX() == vec2)

        
        let rotSide2 = try! CoordinateSystem(spot: home, direction1: vec2, direction2: vec6, useFirst: false, verticalRef: false)
        
        XCTAssert(rotSide2.getAxisX() == vec6)


        let rotSide3 = try! CoordinateSystem(spot: home, direction1: vec2, direction2: vec6, useFirst: false, verticalRef: true)
        
        XCTAssert(rotSide3.getAxisX() == vec1)
 
        
        let rotSide4 = try! CoordinateSystem(spot: home, direction1: vec1, direction2: vec2, useFirst: true, verticalRef: true)
        
        let targetHoriz = Vector3D(i: 0.0, j: -1.0, k: 0.0)
        
        XCTAssert(rotSide4.getAxisX() == targetHoriz)
    }
    
    func testGenToGlobal()   {
        
        let fred = CoordinateSystem()
        
        let pebbles = fred.genToGlobal()
        
        let pristine = Transform()
        
        XCTAssert(pebbles == pristine)
        
        let barney = Point3D(x: 1.0, y: 2.0, z: 3.0)
        
        let wilma = CoordinateSystem.relocate(startingCSYS: fred, betterOrigin: barney)
        
        let bambam = wilma.genToGlobal()
        
        XCTAssertFalse(bambam == pristine)
        
        XCTAssert(bambam.p == 1.0)
        XCTAssert(bambam.r == 2.0)
        XCTAssert(bambam.s == 3.0)

    }
    
    
    func testGenFromGlobal()   {
        
        let fred = CoordinateSystem()
        
        let barney = Point3D(x: 1.0, y: 2.0, z: 3.0)
        
        let wilma = CoordinateSystem.relocate(startingCSYS: fred, betterOrigin: barney)
        
        let betty = wilma.genFromGlobal()
        
        XCTAssert(betty.p == -1.0)
        XCTAssert(betty.r == -2.0)
        XCTAssert(betty.s == -3.0)
        
        let dino = wilma.genToGlobal()
        
        
        let local1 = Point3D(x: 5.0, y: 4.0, z: 3.0)
        let global1 = Point3D.transform(pip: local1, xirtam: dino)

        XCTAssert(global1.x == 6.0)
        XCTAssert(global1.y == 6.0)
        XCTAssert(global1.z == 6.0)
        
        let local2 = Point3D.transform(pip: global1, xirtam: betty)
        
        XCTAssert(local2 == local1)        
        
    }
    
    
    func testRelocate()   {
        
        let home = Point3D(x: 5.0, y: 2.0, z: 1.0)
        
        let sqrt22 = sqrt(2.0) / 2.0
        
        let axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        let axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        let axis3 = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let prong = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        
        let vacation = Point3D(x: -5.0, y: 2.0, z: 1.5)
        
        let tine = CoordinateSystem.relocate(startingCSYS: prong, betterOrigin: vacation)
        
        XCTAssert(tine.getOrigin().x == -5.0)
        XCTAssert(tine.getOrigin().y == 2.0)
        XCTAssert(tine.getOrigin().z == 1.5)

    }
    
    func testEquals()   {
        
        var home = Point3D(x: 5.0, y: 2.0, z: 1.0)
        
        let sqrt22 = sqrt(2.0) / 2.0
        
        var axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        var axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        var axis3 = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        let humpty = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        var dumpty = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        XCTAssert(humpty == dumpty)
        
        
        home = Point3D(x: -4.0, y: 2.0, z: 1.0)
        dumpty = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        XCTAssertFalse(humpty == dumpty)
        

        home = Point3D(x: 5.0, y: 2.0, z: 1.0)
        axis1 = Vector3D(i: -sqrt22, j: -sqrt22, k: 0.0)
        
        dumpty = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        XCTAssertFalse(humpty == dumpty)
        
        
        axis1 = Vector3D(i: sqrt22, j: sqrt22, k: 0.0)
        axis2 = Vector3D(i: sqrt22, j: -sqrt22, k: 0.0)
        
        dumpty = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        XCTAssertFalse(humpty == dumpty)
        
        
        axis2 = Vector3D(i: -sqrt22, j: sqrt22, k: 0.0)
        axis3 = Vector3D(i: 0.0, j: 0.0, k: -1.0)
        
        dumpty = try! CoordinateSystem(spot: home, alpha: axis1, beta: axis2, gamma: axis3)
        
        XCTAssertFalse(humpty == dumpty)
        
    }
    
}
