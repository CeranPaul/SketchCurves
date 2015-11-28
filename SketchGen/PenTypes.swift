//
//  PenTypes.swift
//
//  Created by Paul on 9/5/15.
//  
//

import Foundation

/// Meaning to be associated with various curves.  Used to set pen characteristics in the drawing routine
/// - Notes:  Will probably vary for each different app
public enum PenTypes {
    
    case Default     // Required by some constructors
    
    case Arc
    
    case Sweep
    
    case Box
    
    case Ideal
    
    case Approx
    
}