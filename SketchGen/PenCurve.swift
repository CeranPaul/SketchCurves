//
//  PenCurve.swift
//  CurveLab
//
//  Created by Paul on 10/30/15.
//

import Foundation
import UIKit

protocol PenCurve   {
    
    /// The enum that hints at the meaning of the curve
    var usage: PenTypes   { get set }
    
    /// Volume that encloses the curve
    var extent: OrthoVol   { get }
    
    
    /// Supply the point on the curve for the input parameter value
    func pointAt(t: Double) -> Point3D
    
    /// Retrieve the starting end
    func getOneEnd() -> Point3D
    
    /// Retrieve the finishing end
    func getOtherEnd() -> Point3D
    
    /// Plot the curve.  Your classic example of polymorphism
    func draw(context: CGContext)
    
    /// Figure how far the point is off the curve, and how far along the curve it is.  Useful for picks  
    func resolveBridge(speck: Point3D) -> (along: Double, perp: Double)
    
}
