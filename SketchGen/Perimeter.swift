//
//  Perimeter.swift
//  SketchCurves
//
//  Created by Paul Hollingshead on 12/3/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// A closed boundary that is the result of the sketch
public class Perimeter {
    
    /// The display list
    var pieces: [PenCurve]
    
    /// Whether or not this has no gaps
    var isClosed: Bool
    
    init () {
        
        pieces = [PenCurve]()
        
        isClosed = false
    }
    
    
    
    /// Pile on another curve
    /// It is a possibility to do this by overloading +=
    func add(noob: PenCurve) -> Void   {
        
        if self.pieces.isEmpty  {
            
            pieces.append(noob)   // Use this to start the list
            
        }  else  {   // Find the correct spot, and add this to the array
            
            
        }
        
    }
    
    /// See if the input screen point is near the end of any of the line segments
    func  nearEnd(speck: Point3D, enough: Double) -> Point3D?   {
        
        for var g = 0; g < pieces.count; g++  {
            
            let wire = pieces[g]
            let sep = wire.resolveBridge(speck)
            
            var distance = sqrt(sep.along * sep.along + sep.perp * sep.perp)
            
            if distance < enough   {
                return wire.getOneEnd()
            }
            
            let htgnel = Point3D.dist(wire.getOneEnd(), pt2: wire.getOtherEnd())
            
            let far = sep.along - htgnel
            
            distance = sqrt(far * far + sep.perp * sep.perp)
            
            if distance < enough   {
                return wire.getOtherEnd()
            }
            
        }
        
        return nil   // A new way of doing things
    }
    
    
}

