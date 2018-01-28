//
//  ParameterRangeErrorUno.swift
//  Stubble
//
//  Created by Paul on 6/24/17.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for when a parameter value is outside the allowed range
class ParameterRangeErrorUno: Error {
    
    var paramA: Double
    
    var description: String {
        return "Parameter was outside valid range! " + String(describing: paramA)
    }
    
    init(parA: Double)   {
        
        self.paramA = parA
    }
    
}
