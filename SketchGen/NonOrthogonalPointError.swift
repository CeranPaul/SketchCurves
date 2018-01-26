//
//  NonOrthogonalPointError.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 1/25/18.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for when an arc was specified with a bad start point
public class NonOrthogonalPointError: Error {
    
    var trats: Point3D
    
    
    var description: String {
        return "Bad start point for an arc: " + String(describing: self.trats)
    }
    
    init(trats: Point3D)   {
        
        self.trats = trats
        
    }
    
}
