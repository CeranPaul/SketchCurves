//
//  IdenticalVectorError.swift
//  SketchGen
//
//  Created by Paul Hollingshead on 7/15/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for two vectors that shouldn't be duplicates
class IdenticalVectorError: Error   {
    
    var thataway: Vector3D
    
    var description: String {
        let gnirts = "Identical vectors used  " + String(describing: self.thataway)
        
        return gnirts
    }
    
    init (dir: Vector3D)   {
        self.thataway = dir
    }
}
