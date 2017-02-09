//
//  Perimeter.swift
//  SketchCurves
//
//  Created by Paul on 12/3/15.
//  Copyright © 2016 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

/// A closed boundary that is the result of the sketch
/// Interior voids have only been tested one deep
open class Perimeter {
    
    /// The display list
    var pieces: [PenCurve]
    
    /// Collection of interior voids
    /// This has not been tested with multiple circular holes
    var cutouts: [Perimeter]
    
    /// Whether or not the perimeter has any gaps
    var closed: Bool
    
    init () {
        
        pieces = [PenCurve]()
        
        closed = false
        
        /// Each subset should be ordered
        cutouts = [Perimeter]()
        
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
    
    /// Put in a void
    /// Does no checks for inclusion or overlap
    func addCutout(seeThrough: Perimeter) -> Void   {
        
        cutouts.append(seeThrough)
        
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
    
    /// Find the combined extent
    func getExtent() -> OrthoVol   {
        
        var box = self.pieces[0].extent
        
        for (index, stroke) in self.pieces.enumerated()   {
            if index != 0   {
                box = box + stroke.extent
            }
        }
        
        return box
    }
    
    /// Plot the boundaries.  This will be called by the UIView 'draw' function
    /// Notice that a model-to-display transform is applied
    public func draw(context: CGContext, tform: CGAffineTransform)  {
        
        for stroke in self.pieces   {
            stroke.draw(context: context, tform: tform)
        }
        
        for seeThrough in self.cutouts   {   // Iterate through the cutouts
            
            for stroke in seeThrough.pieces   {
                stroke.draw(context: context, tform: tform)
            }
            
        }   // End of outer loop
        
    }   // End of function 'draw'
    
    
}

