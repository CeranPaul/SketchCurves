//
//  Loop.swift
//  LineSegShow
//
//  Created by Paul on 2/3/18.
//  Copyright © 2018 Ceran Digital Media. All rights reserved.
//

import Foundation

/// An ordered collection of PenCurves that serves as a boundary.
/// Can be used either for the perimeter, or for a cutout.
public class Loop   {
    
    var refCoord: CoordinateSystem
    
    /// The component list
    var pieces: [PenCurve]
    
    /// The nose-to-tail component list
    var ordered: [PenCurve]
    
    
    /// Indications that curves are joined
    internal var bucket: [Rivet]
    
    /// Whether or not this is a complete boundary.  Will get updated each time a curve is added or deleted.
    internal var isClosed:  Bool
    
    
    
    // Will need to have a "remove" function, and will need to modify the Loop status.
    
    
    // May want to be able to shift the starting point
    
    
    init(refCoord: CoordinateSystem)   {
        
        isClosed = false
        
        self.refCoord = refCoord
        
        pieces = [PenCurve]()
        
        bucket = [Rivet]()
        
        ordered = [PenCurve]()
        
    }
    
    
    /// Pile on another curve.  No checks are made.
    /// Some curves may get reversed when the Loop becomes closed.
    /// There are a whole bunch of checks that should be done as part of this process.
    /// Need to check that a duplicate curve is not submitted.
    /// - See: 'testAdd' and 'testCount' under LoopTests
    public func add(noob: PenCurve) -> Void   {
        
        // Need to protect against a zero-length curve, or a duplicate curve
        // Will need a special case for a closed circle.
        
        pieces.append(noob)   // Blindly add this curve
        
        if bucket.count == 0   {   // First curve
            
            var pin = Rivet(oneCurve: noob, location: noob.getOneEnd())
            bucket.append(pin)
            
            pin = Rivet(oneCurve: noob, location: noob.getOtherEnd())
            bucket.append(pin)
            
        }  else  {   // Most curves
            
            var headmate = false
            var tailmate = false
            
            // Loop through bucket members
            for g in 0...bucket.count - 1   {
                
                // Paying attention only to unmated members
                if bucket[g].other == nil    {
                    
                    if !headmate   {
                        if bucket[g].spot == noob.getOneEnd()   {
                            
                            bucket[g].addMate(otherCurve: noob)   // Want this change to get passed back to bucket.
                            headmate = true
                        }
                    }
                    
                    if !tailmate   {
                        if bucket[g].spot == noob.getOtherEnd()   {
                            bucket[g].addMate(otherCurve: noob)
                            tailmate = true
                        }
                    }
                    
                }   // Deal only with unmated members
                
            }   // Loop through bucket members
            
            if !headmate   { bucket.append(Rivet(oneCurve: noob, location: noob.getOneEnd())) }
            if !tailmate   { bucket.append(Rivet(oneCurve: noob, location: noob.getOtherEnd())) }
            
        }
        
        
        self.isClosed = checkIsClosed()
    }
    
    
    
    /// See if the entities form a sealed boundary.
    /// - Returns: Simple flag.
    /// - See: 'testIsClosed' under LoopTests
    public func checkIsClosed() -> Bool   {
        
        /// The flag to be returned
        var flag = false
        
        
        if self.pieces.count == 1   {   // Special case of full circle
            
            let unoType = type(of: self.pieces.first!)
            
            if unoType == Arc.self   {
                
                let myArc = self.pieces.first! as! Arc
                flag = myArc.isFull
                
            }
            
        }  else  {  // The more general case
            
            let qtyflag = bucket.count == pieces.count
            
            let sewedUp = bucket.reduce(true, { f1, f2 in f1 && f2.other != nil } )
            
            flag = qtyflag && sewedUp
        }
        
        return flag
    }
    
    
    
    /// See if the tail is coincident with the following head.
    /// - Parameters:
    ///   - xedni: Index of the current curve.
    /// - Returns: Simple flag.
    /// - See: 'testIsJoined' under LoopTests.
    func isjoined(xedni: Int) -> Bool   {
        
        let tail = pieces[xedni].getOtherEnd()
        let head = pieces[xedni + 1].getOneEnd()
        
        return (tail == head)
    }
    
    
    // TODO: Add a function to sum up the lengths
    
    /// Ensure that the curves go nose-to-tail.
    /// Fills the 'ordered' array.
    /// Will screw up if the Loop isn't closed
    public func align() -> Void   {
        
        // Simple copy if the loop has less than three members
        if pieces.count < 3   {
            
            for wire in pieces   {
                ordered.append(wire)
            }
        }  else {
            
            let stock = pieces[0]
            ordered.append(stock)    // Start the array with this curve
            
            /// Counter of curves put in place
            var linedUp = 1
            
            /// The point shared by two curves
            var common = stock.getOtherEnd()
            
            /// The previous common point
            var prevCommon = stock.getOneEnd()
            
            repeat   {
                
                if let eenie = bucket.index(where: { $0.spot == common })   {
                    
                    // Accomplish this with a switch using a boolean tuple?  (Instead of a tangle of 'if' statements)
                    let early = bucket[eenie].one
                    
                    /// Ordering of point on other curve
                    var mateIsNear: Bool
                    
                    let curIsOne = (early.getOneEnd() == prevCommon)
                    
                    
                    switch curIsOne   {
                        
                    case true:
                        
                        mateIsNear = bucket[eenie].other?.getOneEnd() == common
                        
                    case false:
                        
                        mateIsNear = early.getOneEnd() == common
                        
                    }
                    
                    /// The curve that follows in the proper sequence
                    var next: PenCurve
                    
                    switch (curIsOne, mateIsNear)   {
                        
                    case (true, true):    // The easiest case
                        next = bucket[eenie].other!
                        
                    case (true, false):
                        next = bucket[eenie].other!
                        next.reverse()
                        
                    case (false, true):
                        next = bucket[eenie].one
                        
                    case (false, false):
                        next = bucket[eenie].one
                        next.reverse()
                        
                    }
                    
                    ordered.append(next)   // Add the curve to the ordered list
                    
                    prevCommon = common   // Prepare for the next iteration
                    common = (next.getOtherEnd())
                    linedUp += 1
                    
                    print(String(linedUp) + "  " + String(describing: common))
                    
                }  else  {
                    print("Trouble while aligning")
                    break
                }
                
            } while linedUp < bucket.count
            
        }   // Not the small case
        
    }   // func align
    
    
    
    /// Find the minimum and maximum in both coordinate directions
    /// - Returns: Array of four points.  Min and max in the X direction, and in Y.
    //    public func findMax() -> [Point3D]   {
    //
    //        var bounds = [Point3D]()
    //
    //        return bounds
    //    }
    
}


/// A way of tracking whether or not curves are joined.
/// Does not contain any directionality.
/// Should access control be something else?
public struct Rivet   {
    
    var one: PenCurve
    var other: PenCurve?
    var spot: Point3D
    
    
    public init(oneCurve: PenCurve, location: Point3D)   {
        
        self.one = oneCurve
        self.spot = location
        
    }
    
    public mutating func addMate(otherCurve: PenCurve) -> Void   {
        
        self.other = otherCurve
        
    }
    
    
    /// Check to see if this one covers a desired location.
    public func contains(location: Point3D) -> Bool   {
        
        if self.spot == location   { return true }
        
        return false
    }
    
}

