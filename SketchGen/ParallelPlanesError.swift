//
//  ParallelPlanesError.swift
//  Tesstest
//
//  Created by Paul on 9/21/15.
//

import Foundation

/// Exception for when the planes shouldn't have been parallel - i.e. when trying to intersect them
class ParallelPlanesError: ErrorType {
    
    var enalpA: Plane
    var enalpB: Plane
    
    var description: String {
        return " Two planes were parallel  "
    }
    
    init(enalpA: Plane, enalpB: Plane)   {
        
        self.enalpA = enalpA
        self.enalpB = enalpB
    }
    
    
}