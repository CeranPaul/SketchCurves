//
//  ZeroSweepError.swift
//  SketchGen
//
//  Created by Paul on 1/25/18.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// Exception for when an arc was specified with zero length
public class ZeroSweepError: Error {
    
    var ctr: Point3D
    
    
    var description: String {
        return "Zero sweep specified for an arc: " + String(describing: self.ctr)
    }
    
    init(ctr: Point3D)   {
        
        self.ctr = ctr
        
    }
    
}

