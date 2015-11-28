//
//  CoincidentPointsError.swift
//  CurveLab
//
//  Created by Paul on 10/28/15.
//

import Foundation

/// Exception for when the points should not have be coincident
class CoincidentPointsError: ErrorType {
    
    var ptA: Point3D
    
    var description: String {
        return "Coincident points were specified - no bueno! " + String(ptA)
    }
    
    init(dupePt: Point3D)   {
        
        self.ptA = dupePt
    }
    
    
}