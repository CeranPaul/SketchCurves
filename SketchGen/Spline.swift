//
//  Spline.swift
//  SketchCurves
//
//  Created by Paul on 7/18/16.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

/// Sequence of Cubic curves in 3D - tangent at the interior points
/// This will eventually need to conform to protocol PenCurve
/// Each piece is assumed to be parameterized from 0 to 1
open class Spline: PenCurve   {
    
    // TODO: Explain this in a blog page
    // TODO: Add all of the functions that will make this comply with PenCurve.  And the occasional test.
    // What to do about a closed Spline?
    
    /// Sequence of component curves
    var pieces: [Cubic]
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    open var parameterRange: ClosedRange<Double>   // Never used
    

    
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

        self.pieces.forEach( {$0.setIntent(purpose: PenTypes.ordinary)} )
        
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
}
    
    
    /// Build from an array of points and correponding tangents, probably from screen points
    /// - Parameters:
    ///   - pts: Points on the desired curve
    ///   - tangents: Matched vectors to specify slope
    /// Currently doesn't check the length of input arrays
    init(pts: [Point3D], tangents: [Vector3D])   {
        
        pieces = [Cubic]()
        
        for ptIndex in 1..<pts.count   {
            
            let alpha = pts[ptIndex - 1]   // Retrieve the end points
            let omega = pts[ptIndex]
            
            let tangentA = tangents[(ptIndex - 1) * 2]
            let tangentB = tangents[(ptIndex - 1) * 2 + 1]

            let fresh = Cubic(ptA: alpha, slopeA: tangentA, ptB: omega, slopeB: tangentB)
            
            pieces.append(fresh)
        }
            
        self.usage = PenTypes.ordinary
        
        self.pieces.forEach( {$0.setIntent(purpose: PenTypes.ordinary)} )
        

        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    /// Build from an array of Cubics - typically the result of transforming
    init(curves: [Cubic])   {
        
        self.pieces = curves
        
        self.usage = PenTypes.ordinary
        
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Attach new meaning to the curve.
    public func setIntent(purpose: PenTypes) -> Void  {
        self.usage = purpose
        
        self.pieces.forEach( {$0.setIntent(purpose: purpose)} )

    }
    
    
    /// Fetch the location of an end.
    /// - See: 'getOtherEnd()'
    public func getOneEnd() -> Point3D   {
        
        let locomotive = pieces.first!
        
        return locomotive.getOneEnd()
    }
    
    
    /// Fetch the location of the opposite end.
    /// - See: 'getOneEnd()'
    public func getOtherEnd() -> Point3D   {
        
        let caboose = pieces.last!
        
        return caboose.getOtherEnd()
    }
    
    
    /// Generate an enclosing volume
    public func getExtent() -> OrthoVol   {
        
        var brick = self.pieces.first!.getExtent()
        
        if self.pieces.count > 1   {
            
            for g in 1..<self.pieces.count   {
                brick = brick + self.pieces[g].getExtent()
            }
            
        }
        
        return brick
    }
    
    public func pointAt(t: Double) -> Point3D {
        let dummy = Point3D(x: 0.0, y: 0.0, z: 0.0)
        return dummy
    }
    
    
    /// Change the order of the components in the array, and the order of each component
    public func reverse() -> Void   {
        
        self.pieces.forEach( {$0.reverse()} )
        self.pieces = self.pieces.reversed()
        
    }
    
    
    /// Transform the set.
    /// Problem with the return type.
    public func transform(xirtam: Transform) -> PenCurve   {

        let spaghetti = self.pieces.map( {$0.transform(xirtam: xirtam)} )
        
        let _ = Spline(curves: spaghetti as! [Cubic])
        
        return spaghetti.first!
    }
    

    /// Find the position of a point relative to the spline and its start point.
    /// Useless result at the moment.
    /// - Parameters:
    ///   - speck:  Point near the curve.
    /// - Returns: Tuple of distances relative to the origin
    public func resolveRelative(speck: Point3D) -> (along: Double, away: Double)   {
        
        
        return (1.0, 1.0)
    }
    
    
    /// Plot the curves.  This will be called by the UIView 'drawRect' function
    /// Won't be useful until Spline conforms to PenCurve
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    public func draw(context: CGContext, tform: CGAffineTransform) -> Void  {
        
        self.pieces.forEach( {$0.draw(context: context, tform: tform)} )
        
    }
        

}
