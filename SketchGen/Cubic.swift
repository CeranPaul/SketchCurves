//
//  Cubic.swift
//  SketchCurves
//
//  Created by Paul on 12/14/15.
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
    
    var az: Double   // For a curve in the XY plane, these can be ignored, or set to zero
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
    
    /// Build from two points and two slopes
    /// The assignment statements come from an algebraic manipulation of the equations
    /// in the Wikipedia article on Cubic Hermite spline
    init(ptA: Point3D, slopeA: Vector3D, ptB: Point3D, slopeB: Vector3D)   {
        
        
        self.ax = 2.0 * ptA.x + slopeA.i - 2.0 * ptB.x + slopeB.i
        self.bx = -3.0 * ptA.x - 2.0 * slopeA.i + 3.0 * ptB.x - slopeB.i
        self.cx = slopeA.i
        self.dx = ptA.x
        
        self.ay = 2.0 * ptA.y + slopeA.j - 2.0 * ptB.y + slopeB.j
        self.by = -3.0 * ptA.y - 2.0 * slopeA.j + 3.0 * ptB.y - slopeB.j
        self.cy = slopeA.j
        self.dy = ptA.y
        
        self.az = 2.0 * ptA.z + slopeA.k - 2.0 * ptB.z + slopeB.k
        self.bz = -3.0 * ptA.z - 2.0 * slopeA.k + 3.0 * ptB.z - slopeB.k
        self.cz = slopeA.k
        self.dz = ptA.z
        
    }
    
    
    /// Supply the point on the curve for the input parameter value
    /// Some notations show "t" as the parameter, instead of "u"
    func pointAt(u: Double) -> Point3D   {
        
        let u2 = u * u
        let u3 = u2 * u
        
           // This notation came from "Fundamentals of Interactive Computer Graphics" by Foley and Van Dam
           // Warning!  The relationship of coefficients and powers of u might be unexpected, as notations vary
        let myX = ax * u3 + bx * u2 + cx * u + dx
        let myY = ay * u3 + by * u2 + cy * u + dy
        let myZ = az * u3 + bz * u2 + cz * u + dz
        
        return Point3D(x: myX, y: myY, z: myZ)
    }
    
    /// Differentiate to find the tangent vector for the input parameter
    /// Some notations show "t" as the parameter, instead of "u"
    /// - Returns:
    ///   - tan:  Non-normalized vector
    func tangentAt(u: Double) -> Vector3D   {
        
        let u2 = u * u

        let myI = 3.0 * ax * u2 + 2.0 * bx * u + cx
        let myJ = 3.0 * ay * u2 + 2.0 * by * u + cy
        let myK = 3.0 * az * u2 + 2.0 * bz * u + cz
        
        return Vector3D(i: myI, j: myJ, k: myK)    // Notice that this is not normalized!
    }
    
    
    
    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext)  {
        
        var xCG: CGFloat = CGFloat(self.ax)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.ay)
        
        CGContextMoveToPoint(context, xCG, yCG)
        
        
        for g in 1...20   {
            
            let stepU = Double(g) * 0.05   // Gee, this is brittle!
            xCG = CGFloat(pointAt(stepU).x)
            yCG = CGFloat(pointAt(stepU).y)
            CGContextAddLineToPoint(context, xCG, yCG)
        }
        
        CGContextStrokePath(context)
        
    }
    
    // What's the right way to check for equivalence?
    
    // TODO: Figure a way to do an offset curve
    
}
