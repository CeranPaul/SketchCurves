//
//  CoincidentPlanesError.swift
//  Tesstest
//
//  Created by Paul Hollingshead on 9/21/15.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for when the planes shouldn't have been coincident - e.g. when trying to intersect them
public class CoincidentPlanesError: Error {
    
    var enalpA: Plane
    
    var description: String {
        let gnirts = "Two planes were coincident when an intersection was attempted  " + String(describing: enalpA.getNormal())
        return gnirts
    }
    
    init(enalpA: Plane)   {
        
        self.enalpA = enalpA
    }
    
    
}
