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
    
    /// Whether or not the perimeter has any gaps
    var closed: Bool
    
    init () {
        
        pieces = [PenCurve]()
        
        closed = false
    }
    
    
    
    /// Pile on another curve
    /// There are a whole bunch of checks that should be done as part of this process
    func add(noob: PenCurve) -> Void   {
        
        if self.pieces.isEmpty  {
            
            pieces.append(noob)   // Use this to start the list
            
        }  else  {   // Look for a connecting spot, and add this to the array
            
              // Look for an end point that is the same as the current beginning point
            
            /// Whether or not the input curve could be connected
            var didConnect = false
            for (index, edge) in pieces.enumerate()   {
                
                let head = edge.getOneEnd()
                let tail = edge.getOtherEnd()
                
                if  noob.getOneEnd() == tail  {
                    pieces.insert(noob, atIndex: index + 1)
                    didConnect = true
                    break
                }  else if noob.getOtherEnd() == tail   {
                    noob.reverse()
                    pieces.insert(noob, atIndex: index + 1)
                    didConnect = true
                    break
                }  else if noob.getOneEnd() == head  {
                    noob.reverse()
                    pieces.insert(noob, atIndex: index)
                    didConnect = true
                    break
                }  else if noob.getOtherEnd() == head   {
                    pieces.insert(noob, atIndex: index)
                    didConnect = true
                    break
                }
            }   // End of for loop
            
            if !didConnect   { pieces.append(noob) }   // Add to the array at an arbitrary location
            
            
            
            
        }   // End of 'else' clause
        
    }
    
    /// See if the input screen point is near the end of any of the line segments
    func  nearEnd(speck: Point3D, enough: Double) -> Point3D?   {
        
        for var g = 0; g < pieces.count; g++  {
            
            let wire = pieces[g]
            let sep = wire.resolveNeighbor(speck)
            
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

