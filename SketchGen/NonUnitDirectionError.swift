//
//  NonUnitDirectionError.swift
//
//  Created by Paul on 12/10/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
//

import Foundation
/// Exception for failure to supply a unit vector when constructing a line or plane
class NonUnitDirectionError: ErrorType {
    
    var thataway: Vector3D
    
    var description: String {
        let gnirts = "Direction for a line or plane was not given as a unit vector  " + String(self.thataway)
        return gnirts
    }
    
    init(dir: Vector3D)   {
        
        self.thataway = dir
    }
    
    
}