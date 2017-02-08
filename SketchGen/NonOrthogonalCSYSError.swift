//
//  NonOrthogonalCSYSError.swift
//  SketchGen
//
//  Created by Paul on 6/6/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

class NonOrthogonalCSYSError: Error {
    
    var description: String {
        let gnirts = "Bad direction inputs for a coordinate system"
        return gnirts
    }
    
}

