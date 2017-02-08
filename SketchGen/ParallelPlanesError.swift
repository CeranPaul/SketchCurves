//
//  ParallelPlanesError.swift
//  Tesstest
//
//  Created by Paul on 9/21/15.
//

import Foundation

/// Exception for when the planes shouldn't have been parallel - i.e. when trying to intersect them
class ParallelPlanesError: Error {
    
    var enalpA: Plane
    
    
    var description: String {
        let gnirts = "Function failed because two planes were parallel " + String(describing: enalpA.getNormal())
        return gnirts
    }
    
    init(enalpA: Plane)   {
        
        self.enalpA = enalpA
    }
    
}
