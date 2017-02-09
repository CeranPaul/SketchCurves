//
//  Perimeter.swift
//  SketchCurves
//
//  Created by Paul on 12/3/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// A closed boundary that is the result of the sketch
/// No provision for interior voids
open class Perimeter {
    
    /// The display list
    var pieces: [PenCurve]
    
    /// Whether or not the perimeter has any gaps
    var closed: Bool
    
    init () {
        
        pieces = [PenCurve]()
        
        closed = false
    }
    
    
    
    /// Pile on another curve
    /// Some curves may get reversed as a result of this function
    /// There are a whole bunch of checks that should be done as part of this process
    func add(_ noob: PenCurve) -> Void   {
        
        if self.pieces.isEmpty  {
            
            pieces.append(noob)   // Use this curve to start the list
            
        }  else  {   // Look for a single connecting spot, and add this to the array
            
            /// Whether or not a single end of the input curve could be connected
            var didConnect = false
            
            // Look for an end point that is the same as the current beginning point
            
            for (index, edge) in pieces.enumerated()   {
                
                let head = edge.getOneEnd()
                let tail = edge.getOtherEnd()
                
                if  noob.getOneEnd() == tail  {
                    pieces.insert(noob, at: index + 1)
                    didConnect = true
                    break
                }  else if noob.getOtherEnd() == tail   {
                    noob.reverse()
                    pieces.insert(noob, at: index + 1)
                    didConnect = true
                    break
                }  else if noob.getOneEnd() == head  {
                    noob.reverse()
                    pieces.insert(noob, at: index)
                    didConnect = true
                    break
                }  else if noob.getOtherEnd() == head   {
                    pieces.insert(noob, at: index)
                    didConnect = true
                    break
                }
                
            }   // End of for loop
            
            if !didConnect   { pieces.append(noob) }   // Add to the end of the array
            
        }   // End of outside 'else' clause
        
    }
    
    /// Check to see that the chain is unbroken, ordered properly, and closes on itself
    func isClosed() -> Bool   {
        
        var closedFlag = true
        
        for (index, edge) in self.pieces.enumerated()   {
            
            let plug = edge.getOtherEnd()
            
            /// Second point of pair
            var socket: Point3D
            
            if index == self.pieces.count - 1   {
                socket = self.pieces[0].getOneEnd()
            }  else  {
                socket = self.pieces[index + 1].getOneEnd()
            }
            
            let pairFlag = plug == socket
            
            closedFlag = closedFlag && pairFlag
            
        }
        
        return closedFlag
    }
    
    
    
    
    /// See if the input screen point is near the end of any of the line segments
    func  nearEnd(_ speck: Point3D, enough: Double) -> Point3D?   {
        
        for g in 0..<pieces.count  {
            
            let wire = pieces[g]
            let sep = wire.resolveNeighbor(speck: speck)
            
            var distance = sqrt(sep.along.length() + sep.perp.length())
            
            if distance < enough   {
                return wire.getOneEnd()
            }
            
            let htgnel = Point3D.dist(pt1: wire.getOneEnd(), pt2: wire.getOtherEnd())
            
            let far = sep.along.length() - htgnel
            
            distance = sqrt(far * far + sep.perp.length())
            
            if distance < enough   {
                return wire.getOtherEnd()
            }
            
        }
        
        return nil   // A new way of doing things
    }
    
    
}

