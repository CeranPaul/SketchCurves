//
//  NonCoPlanarLinesError.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 1/10/16.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for when the lines should have been coplanar - i.e. when trying to intersect them
class NonCoPlanarLinesError: Error {
    
    var enilA: Line
    var enilB: Line
    
    var description: String {
        let gnirts = "Two lines were coincident when an intersection was attempted  " + String(describing: enilA.getOrigin()) + String(describing: enilA.getDirection()) + " and " + String(describing: enilB.getOrigin()) + String(describing: enilB.getDirection())
        
        return gnirts
    }
    
    init(enilA: Line, enilB: Line)   {
        
        self.enilA = enilA
        self.enilB = enilB
    }
    
    
}
