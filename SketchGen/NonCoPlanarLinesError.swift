//
//  NonCoPlanarLinesError.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 1/10/16.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for when the lines should have been coplanar - i.e. when trying to intersect them
class NonCoPlanarLinesError: ErrorType {
    
    var enilA: Line
    var enilB: Line
    
    var description: String {
        let gnirts = "Two lines were coincident when an intersection was attempted  " + String(enilA.getOrigin()) + String(enilA.getDirection()) + " and " + String(enilB.getOrigin()) + String(enilB.getDirection())
        
        return gnirts
    }
    
    init(enilA: Line, enilB: Line)   {
        
        self.enilA = enilA
        self.enilB = enilB
    }
    
    
}