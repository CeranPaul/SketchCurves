//
//  PenTypes.swift
//  SketchCurves
//
//  Created by Paul on 9/5/15.
//  Copyright © 2018 Ceran Digital Media. See LICENSE.md
//
//

import Foundation

/// Meaning that can be associated with various curves.  Used to set pen characteristics in the drawing routine
/// - Notes:  Will probably vary for each different app.  Matches up with a switch statement in 'Easel'.
public enum PenTypes {
    
    case arc
    
    case sweep
    
    case extent
    
    case ideal
    
    case approx
    
    case ordinary
    
}
