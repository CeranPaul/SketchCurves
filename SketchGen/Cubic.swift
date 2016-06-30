//
//  Cubic.swift
//  SketchCurves
//
//  Created by Paul Hollingshead on 12/14/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import UIKit

/// Curve defined by polynomials for each coordinate direction
public class Cubic   {
    
    var ax: Double
    var bx: Double
    var cx: Double
    var dx: Double
    
    var ay: Double
    var by: Double
    var cy: Double
    var dy: Double
    
    var az: Double   // For a lengthy period, these will be ignored, or set to zero
    var bz: Double
    var cz: Double
    var dz: Double
    
    
    
    /// Build from 12 individual parameters
    init (ax: Double, bx: Double, cx: Double, dx: Double, ay: Double, by: Double, cy: Double, dy: Double, az: Double, bz: Double, cz: Double, dz: Double)   {
        
        self.ax = ax
        self.bx = bx
        self.cx = cx
        self.dx = dx
        
        self.ay = ay
        self.by = by
        self.cy = cy
        self.dy = dy
        
        self.az = az
        self.bz = bz
        self.cz = cz
        self.dz = dz
        
    }
    
    /// Supply the point on the curve for the input parameter value
    func pointAt(u: Double) -> Point3D   {
        
        let u2 = u * u
        let u3 = u2 * u
        
           // Warning!  The relationship of coefficients and powers of u might be unexpected, as notations vary
        let myX = ax * u3 + bx * u2 + cx * u + dx
        let myY = ay * u3 + by * u2 + cy * u + dy
        let myZ = az * u3 + bz * u2 + cz * u + dz
        
        return Point3D(x: myX, y: myY, z: myZ)
    }
    
    /// Differentiate to find the tangent vector for the input parameter
    func tangentAt(u: Double) -> Vector3D   {
        
        let u2 = u * u

        let myI = 3.0 * ax * u2 + 2.0 * bx * u + cx
        let myJ = 3.0 * ay * u2 + 2.0 * by * u + cy
        let myK = 3.0 * az * u2 + 2.0 * bz * u + cz
        
        return Vector3D(i: myI, j: myJ, k: myK)    // Notice that this is not normalized!
    }
    
    
    /// Cross the tangent with a Z vector to get the normal
    func normalAt(u: Double) -> Vector3D   {
        
        let ZVec = Vector3D(i: 0.0, j: 0.0, k: 1.0)
        
        var tanHere = tangentAt(u)
        tanHere.normalize()
        
        return try! Vector3D.crossProduct(ZVec, rhs: tanHere)   // Not normalized
    }
    
    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext)  {
        
        var xCG: CGFloat = CGFloat(self.ax)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.ay)
        
        CGContextMoveToPoint(context, xCG, yCG)
        
        
        for var g = 1; g <= 20; g += 1   {   // I don't know how to do this with a different loop style
            
            let stepU = Double(g) * 0.05
            xCG = CGFloat(pointAt(stepU).x)
            yCG = CGFloat(pointAt(stepU).y)
            CGContextAddLineToPoint(context, xCG, yCG)
        }
        
        CGContextStrokePath(context)
        
    }
    
}
