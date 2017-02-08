//
//  ParallelLinesError.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 1/10/16.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for when the lines shouldn't have been parallel - i.e. when trying to intersect them
class ParallelLinesError: Error {
    
    var enil: Line
    
    
    var description: String {
        let gnirts = "Function failed because two lines were parallel " + String(describing: enil.getDirection())
        return gnirts
    }
    
    init(enil: Line)   {
        
        self.enil = enil
    }
    
}
