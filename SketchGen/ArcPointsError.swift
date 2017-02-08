//
//  ArcPointsError.swift
//  BoxChopDemo
//
//  Created by Paul on 11/14/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for when the points should not have be coincident
class ArcPointsError: Error {
    
    var ptA: Point3D
    var ptB: Point3D
    var ptC: Point3D
    
    
    
    var description: String {
        return "Three points cannot make an arc: " + String(describing: ptA) + ", " + String(describing: ptB) + ", " + String(describing: ptC)
    }
    
    init(badPtA: Point3D, badPtB: Point3D, badPtC: Point3D)   {
        
        self.ptA = badPtA
        self.ptB = badPtB
        self.ptC = badPtC
    }
    
    
}
