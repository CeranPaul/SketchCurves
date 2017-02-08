//
//  PenTypes.swift
//  SketchCurves
//
//  Created by Paul on 9/5/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//
//

import Foundation

/// Meaning that can be associated with various curves.  Used to set pen characteristics in the drawing routine
/// - Notes:  Will probably vary for each different app
public enum PenTypes {
    
    // TODO: Change this term to "Ordinary", and update at least LineSeg and Arc
    case `default`     // Required by some constructors
    
    case arc
    
    case sweep
    
    case box
    
    case ideal
    
    case approx
    
}
