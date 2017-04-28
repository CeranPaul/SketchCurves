//
//  Spline.swift
//  SketchCurves
//
//  Created by Paul on 7/18/16.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

// TODO: Explain this in a blog page

/// End-to-end Cubic curves in 3D
/// This will eventually need to conform to protocol PenCurve
/// Each piece is assumed to be parameterized from 0 to 1
open class Spline   {
    
    var pieces: [Cubic]
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    

    /// Build from an ordered array of points using finite differences
    /// See the Wikipedia article on Cubic Hermite splines
    init(pts: [Point3D])   {
        
        pieces = [Cubic]()
        
        var deltaX = pts[1].x - pts[0].x
        var deltaY = pts[1].y - pts[0].y
        var deltaZ = pts[1].z - pts[0].z
        
        /// Because of the above assumption that each piece is parameterized in the range of 0 to 1
        var slopePrior = Vector3D(i: deltaX, j: deltaY, k: deltaZ)
        
        /// Value will be calculated with each iteration in the loop
        var slopeNext: Vector3D
        
        for index in 1..<pts.count - 1  {
            
            deltaX = pts[index + 1].x - pts[index].x
            deltaY = pts[index + 1].y - pts[index].y
            deltaZ = pts[index + 1].z - pts[index].z
            
            slopeNext = Vector3D(i: deltaX, j: deltaY, k: deltaZ)
            
            let slopeFresh = (slopePrior + slopeNext) * 0.5   // Average
            
            let veer = Cubic(ptA: pts[index - 1], slopeA: slopePrior, ptB: pts[index], slopeB: slopeFresh)
            pieces.append(veer)   // This might be a good place for a diagram showing the array indexing of points and curves
            
            slopePrior = slopeFresh   // Prepare for the next iteration
            
        }
        
        deltaX = pts[pts.count - 1].x - pts[pts.count - 2].x
        deltaY = pts[pts.count - 1].y - pts[pts.count - 2].y
        deltaZ = pts[pts.count - 1].z - pts[pts.count - 2].z
        
        slopeNext = Vector3D(i: deltaX, j: deltaY, k: deltaZ)
        
        let veer = Cubic(ptA: pts[pts.count - 2], slopeA: slopePrior, ptB: pts[pts.count - 1], slopeB: slopeNext)
        pieces.append(veer)   // Final piece in the array
        
        self.usage = PenTypes.ordinary
    }
    
    //TODO: Add all of the functions that will make this comply with PenCurve.  And the occasional test.
}
