//
//  Transform.swift
//  SketchCurves
//
//  Created by Paul Hollingshead on 1/17/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import simd

public class Transform   {
    
    var mtx: double4x4
    
    /// Construct an identity matrix
    init()   {
        mtx = double4x4(diagonal: [1.0, 1.0, 1.0, 1.0])
    }
    
    /// Construct a matrix for pure translation
    init (deltaX: Double, deltaY: Double, deltaZ: Double)   {
        
        mtx = double4x4([[1.0, 0.0, 0.0, deltaX],
                         [0.0, 1.0, 0.0, deltaY],
                         [0.0, 0.0, 1.0, deltaZ],
                         [0.0, 0.0, 0.0, 1.0]])
        
    }
    
    /// Construct a matrix to do scaling
    /// scaleY should perhaps be negated for screen display
    init (scaleX: Double, scaleY: Double, scaleZ: Double)   {
        
        mtx = double4x4([[scaleX, 0.0, 0.0, 0.0],
                         [0.0, scaleY, 0.0, 0.0],
                         [0.0, 0.0, scaleZ, 0.0],
                         [0.0, 0.0, 0.0, 1.0]])
        
    }
    
    
    /// Construct a matrix for rotation around a single axis
    /// Angle should be in radians
    init(rotationAxis: Axis, angleRad: Double)   {
        
        let trigCos = cos(angleRad)
        let trigSin = sin(angleRad)
        
        switch rotationAxis   {
            
        case .X:   mtx = double4x4([[1.0, 0.0, 0.0, 0.0],
                                    [0.0, trigCos, trigSin, 0.0],
                                    [0.0, -trigSin, trigCos, 0.0],
                                    [0.0, 0.0, 0.0, 1.0]])
        
        case .Y:   mtx = double4x4([[trigCos, 0.0, trigSin, 0.0],
                                    [0.0, 1.0, 0.0, 0.0],
                                    [-trigSin, 0.0, trigCos, 0.0],
                                    [0.0, 0.0, 0.0, 1.0]])

        case .Z:   mtx = double4x4([[trigCos, trigSin, 0.0, 0.0],
                                    [-trigSin, trigCos, 0.0, 0.0],
                                    [0.0, 0.0, 1.0, 0.0],
                                    [0.0, 0.0, 0.0, 1.0]])
            
        }
    }
    
    
}

public enum Axis {
    
    case X
    
    case Y
    
    case Z

}