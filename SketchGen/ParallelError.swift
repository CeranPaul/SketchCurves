//
//  ParallelError.swift
//  Tesstest
//
//  Created by Paul on 9/19/15.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.
//

import Foundation

public class ParallelError: Error {
    
    var enil: Line
    var enalp: Plane
    
    var description: String {
        return " Line and plane were parallel  " + String(describing: enil.getDirection())
    }
    
    init(enil: Line, enalp: Plane)   {
        
        self.enil = enil
        self.enalp = enalp
    }
    
    
}
