//
//  CoincidentPlanesError.swift
//  Tesstest
//
//  Created by Paul Hollingshead on 9/21/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for when the planes shouldn't have been coincident - i.e. when trying to intersect them
class CoincidentPlanesError: ErrorType {
    
    var enalpA: Plane
    var enalpB: Plane
    
    var description: String {
        return " Two planes were coincident when an intersection was attempted  "
    }
    
    init(enalpA: Plane, enalpB: Plane)   {
        
        self.enalpA = enalpA
        self.enalpB = enalpB
    }
    
    
}