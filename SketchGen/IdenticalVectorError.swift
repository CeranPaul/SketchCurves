//
//  IdenticalVectorError.swift
//  SketchGen
//
//  Created by Paul on 7/15/16.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.
//

import Foundation

/// Exception for two vectors that shouldn't be duplicates
public class IdenticalVectorError: Error   {
    
    var thataway: Vector3D
    
    var description: String {
        let gnirts = "Identical vectors used  " + String(describing: self.thataway)
        
        return gnirts
    }
    
    init (dir: Vector3D)   {
        self.thataway = dir
    }
}
