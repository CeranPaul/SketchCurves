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
    public init()   {
        mtx = double4x4(diagonal: [1.0, 1.0, 1.0, 1.0])
    }
    
    /// Construct a matrix for pure translation
    /// - Warning:  This looks to be the transpose of how this is normally taught
    init (deltaX: Double, deltaY: Double, deltaZ: Double)   {
        
        mtx = double4x4([[1.0, 0.0, 0.0, deltaX],
                         [0.0, 1.0, 0.0, deltaY],
                         [0.0, 0.0, 1.0, deltaZ],
                         [0.0, 0.0, 0.0, 1.0]])
        
    }
    
    /// Construct a matrix to do scaling
    /// scaleY should perhaps be negated for screen display
    public init (scaleX: Double, scaleY: Double, scaleZ: Double)   {
        
        mtx = double4x4([[scaleX, 0.0, 0.0, 0.0],
                         [0.0, scaleY, 0.0, 0.0],
                         [0.0, 0.0, scaleZ, 0.0],
                         [0.0, 0.0, 0.0, 1.0]])
        
    }
    
    
    /// Construct a matrix for rotation around a single axis
    /// - Parameter rotationAxis Center for rotation.  Should be a member of enum Axis
    /// - Parameter angleRad Desired rotation in radians
    /// - Warning:  These each look to be the transpose of how this is normally taught
    public init(rotationAxis: Axis, angleRad: Double)   {
        
        let trigCos = cos(angleRad)
        let trigSin = sin(angleRad)
        
        switch rotationAxis   {
            
        case .X:   mtx = double4x4([[1.0, 0.0, 0.0, 0.0],
                                    [0.0, trigCos, -trigSin, 0.0],
                                    [0.0, trigSin, trigCos, 0.0],
                                    [0.0, 0.0, 0.0, 1.0]])
        
        case .Y:   mtx = double4x4([[trigCos, 0.0, trigSin, 0.0],
                                    [0.0, 1.0, 0.0, 0.0],
                                    [-trigSin, 0.0, trigCos, 0.0],
                                    [0.0, 0.0, 0.0, 1.0]])

        case .Z:   mtx = double4x4([[trigCos, -trigSin, 0.0, 0.0],
                                    [trigSin, trigCos, 0.0, 0.0],
                                    [0.0, 0.0, 1.0, 0.0],
                                    [0.0, 0.0, 0.0, 1.0]])
            
        }
    }
    
    /// Return the inverse of the 4 x 4
    public func getInverse() -> double4x4  {
        return self.mtx.inverse
    }
    
}


/// Simple parameter to indicate axis of rotation
public enum Axis {
    
    case X
    
    case Y
    
    case Z

}