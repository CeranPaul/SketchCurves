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
    
    /// The component list
    var pieces: [PenCurve]
    
    /// Collection of interior voids
    /// This has not been tested with multiple circular holes
    var cutouts: [Perimeter]
    
    /// Whether or not the perimeter has any gaps.  A candidate for lazy initialization.  Or replacement by "isClosed"
    var closed: Bool
    
    init () {
        
        pieces = [PenCurve]()
        
        /// Each subset should be ordered
        cutouts = [Perimeter]()
        
        closed = false
    }
    
    
    /// Copy with a coordinate transformation
    init (untransformed: Perimeter, xirtam: Transform)   {
        
        self.pieces = [PenCurve]()
        
        for swoosh in untransformed.pieces   {   // Iterate through the boundary curves
            let rocked = try! swoosh.transform(xirtam: xirtam)
            self.pieces.append(rocked)
        }
        
        
        /// Each subset should be ordered
        cutouts = [Perimeter]()
        
        for seethrough in untransformed.cutouts   {   // Iterate through the voids
            
            /// The curves that make up a cutout for the fresh Perimeter
            let missing = Perimeter()
            
            for swoosh in seethrough.pieces   {   // Iterate through a set of curves
                let rocked = try! swoosh.transform(xirtam: xirtam)
                missing.add(noob: rocked)
            }
            
            self.cutouts.append(missing)
        }
        
        self.closed = untransformed.closed
    }
    
    
    
    /// Pile on another curve
    /// Some curves may get reversed as a result of this function
    /// There are a whole bunch of checks that should be done as part of this process
    /// - See: 'testOrdering' under PerimeterTests
    func add(noob: PenCurve) -> Void   {
        
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
    
    /// Find the combined extent
    /// What happens if this gets called before any curves have been added?
    func getExtent() -> OrthoVol   {
        
        var box = self.pieces[0].getExtent()
        
        for (index, stroke) in self.pieces.enumerated()   {
            if index != 0   {
                box = box + stroke.getExtent()
            }
        }
        
        return box
    }
    
    /// Check to see that the chain is unbroken, ordered properly, and closes on itself
    /// - See: 'testOrdering' under PerimeterTests
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
    
    
    /// See if the input screen point is near an unconnected end of any curve
    /// Ignore endpoints that are already connected
    /// Choose closest if there is more than one hit
    /// Probably blows up if no curves have been added
    /// - Parameters:
    ///   - speck:  Testing point in model coordinates
    ///   - enough:  Acceptable closeness
    /// - Returns: Closest of the curve endpoints, if near enough, or nil
    func  nearEnd(speck: Point3D, enough: Double) -> Point3D?   {
        
        for g in 0..<pieces.count  {   // Is this actually just a lengthy reduce?
            
            let wire = pieces[g]
            let sep = wire.resolveRelative(speck: speck)
            
            var distance = sqrt(sep.along.length() + sep.perp.length())
            
            if distance < enough   {
                return wire.getOneEnd()
            }
            
            /// Gee, this might not be the best idea for curves
            let htgnel = Point3D.dist(pt1: wire.getOneEnd(), pt2: wire.getOtherEnd())
            
            let far = sep.along.length() - htgnel
            
            distance = sqrt(far * far + sep.perp.length())
            
            if distance < enough   {
                return wire.getOtherEnd()
            }
            
        }
        
        return nil   // A new way of doing things
    }
    
    
    /// Plot the boundary and cutout curves.  This will be called by the UIView 'draw' function
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
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
    
    /// Create a String that is suitable JavaScript to draw the Cubic
    /// Assumes that the context has a plot location of the starting point for the Cubic
    /// - Parameters:
    ///   - xirtam:  Model-to-display transform
    /// - Returns: String consisting of JavaScript to plot
    public func jsDraw(xirtam: Transform) -> String {
        
        var largeString = "context.save();\n"
        
        let firstStroke = self.pieces.first!
        let startPoint = firstStroke.getOneEnd()
        
        let movePoint = startPoint.transform(xirtam: xirtam)
        
        let endX = Int(movePoint.x + 0.5)   // The default is to round towards zero
        let endY = Int(movePoint.y + 0.5)
        
        largeString += "context.moveTo(" + String(endX) + ", " + String(endY) + ");\n"

        largeString += "context.restore();\n"
        
        return largeString
    }
    
}

/// Uses only the point coordinates
struct HashTerminator: Hashable   {
    
    var term: Point3D
    var curveIndex: Int
    var near: Bool
    var instances = 1
    
    init(ptA: Point3D, curveRef: Int, close: Bool)   {
        
        self.term = ptA
        self.curveIndex = curveRef
        self.near = close
        
    }
    
    public mutating func increment() -> Void   {
        
        self.instances += 1
        
    }
    
    
    func recordTerminator(pip: Point3D, curveRef: Int, close: Bool, bundle: inout Set<HashTerminator>) -> Void   {
        
        let finish = HashTerminator(ptA: pip, curveRef: curveRef, close: close)
        
        if bundle.contains(finish)   {
            let xedni = bundle.index(of: finish)
            var temp = bundle[xedni!]
            bundle.remove(temp)
            temp.increment()
            bundle.insert(temp)
        }  else  {
            bundle.insert(finish)
        }
        
    }
    
    var hashValue: Int   {
        
        get  {
            return term.hashValue
        }
    }
    
    /// Copied from Point3D
    public static func == (lhs: HashTerminator, rhs: HashTerminator) -> Bool   {
        
        let separation = Point3D.dist(pt1: lhs.term, pt2: rhs.term)
        
        return separation < Point3D.Epsilon
    }
    
}
