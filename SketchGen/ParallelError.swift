//
//  ParallelError.swift
//  Tesstest
//
//  Created by Paul on 9/19/15.
//
//

import Foundation

class ParallelError: ErrorType {
    
    var enil: Line
    var enalp: Plane
    
    var description: String {
        return " Line and plane were parallel  "
    }
    
    init(enil: Line, enalp: Plane)   {
        
        self.enil = enil
        self.enalp = enalp
    }
    
    
}