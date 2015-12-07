//
//  Arc.swift
//
//  Created by Paul Hollingshead on 11/7/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation
import UIKit

/// A circular arc, either whole, or a portion
public class Arc: PenCurve {
    
    /// Point around which the arc is swept
    var ctr: Point3D
    
    /// Beginning point
    var start: Point3D
    
    /// End point
    var finish: Point3D
    
    /// Derived radius of the Arc
    var rad: Double
    
    /// Whether or not this is a complete circle
    var isFull: Bool
    
    /// Angle (in radians) of the start point
    var startAngle: Double
    
    /// Angle (in radians) of the finish point
    var finishAngle: Double
    
    /// The sweep range
    var range: Double
    
    /// Which direction should be swept?
    var isClockwise:  Bool
    
    /// The enum that hints at the meaning of the curve
    var usage: PenTypes
    
    /// The box that contains the curve
    var extent: OrthoVol
    
    
    
    /// Build an arc from three points
    /// - Throws: CoincidentPointsError, ArcPointsError
    public init(center: Point3D, end1: Point3D, end2: Point3D, isCW: Bool) throws {
        
        self.ctr = center
        self.start = end1
        self.finish = end2
        
        self.rad = Point3D.dist(self.ctr, pt2: self.start)
        
        self.isFull = false
        if self.start == self.finish   { self.isFull = true }
        
        if self.isFull   {
            self.startAngle = 0.0
            self.finishAngle = 2.0 * M_PI
        }  else  {
            self.startAngle = Point3D.angleAbout(self.ctr, tniop: self.start)
            self.finishAngle = Point3D.angleAbout(self.ctr, tniop: self.finish)
        }
        
        self.range = 2.0 * M_PI   // This can get modified below
        
        self.isClockwise = isCW
        
        self.usage = PenTypes.Default   // Use 'setIntent' to attach the desired value
        
        // Dummy assignment because of the peculiarities of being an init
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        
        
            // Because this is an 'init', a guard statement cannot be used at the top
        if end1 == center || end2 == center { throw CoincidentPointsError(dupePt: center) }
        
           // See if an arc can actually be made from the three given inputs
        if !Arc.isArcable(center, end1: start, end2: finish)   { throw ArcPointsError(badPtA: center, badPtB: start, badPtC: finish)  }
        
           // Do computationally expensive routines only if you have a valid set of inputs
        self.extent = figureExtent()    // Replace the dummy value
        
        if !self.isFull   { self.range = findRange() }
        
    }
    
    
    /// Find the point along this line segment specified by the parameter 't'
    /// - Warning:  No checks are made for the value of t being inside some range
    public func pointAt(t: Double) -> Point3D  {
        
        let deltaAngle = t * self.range
        
        let spot = pointAtAngle(self.startAngle + deltaAngle)
     
        return spot
    }
    
    /// Angle should be in radians
    /// Assumes XY plane
    public func pointAtAngle(theta: Double) -> Point3D  {
        
        let deltaX = self.rad * cos(theta)
        let deltaY = self.rad * sin(theta)
        
        return Point3D(x: self.ctr.x + deltaX, y: self.ctr.y + deltaY, z: self.ctr.z)
    }
    
    /// Attach new meaning to the curve
    public func setIntent(purpose: PenTypes)   {
        
        self.usage = purpose
    }
    
    public func getOneEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        return start
    }
    
    public func getOtherEnd() -> Point3D {   // This may not give the correct answer, depend on 'isClockwise'
        return finish
    }
    
    public func getRadius() -> Double   {
        return rad
    }
    
    
    /// Plot the arc segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext)  {
        
        let xCG: CGFloat = CGFloat(self.ctr.x)    // Convert to "CGFloat", and throw out Z coordinate
        let yCG: CGFloat = CGFloat(self.ctr.y)
        
        var dirFlag: Int32 = 1
        if !self.isClockwise  { dirFlag = 0 }
        
        CGContextAddArc(context, xCG, yCG, CGFloat(self.rad), CGFloat(self.startAngle), CGFloat(self.finishAngle), dirFlag)
        
        CGContextStrokePath(context)
        
    }
    
    /// Determine the range of angles covered by the arc
    func findRange() -> Double   {
        
        if self.isFull   {  return 2.0 * M_PI  }   // This value should have been set along with the flag
            
        else  {
            
            /// Vector from the center towards the start point
            var radStart = Vector3D.built(self.ctr, towards: self.start)
            radStart.normalize()

            var radFinish = Vector3D.built(self.ctr, towards: self.finish)
            radFinish.normalize()
            
            let projection = Vector3D.dotProduct(radStart, rhs: radFinish)
        
            /// The raw material for determining the range
            let angleStock = acos(projection)
            
            
        
            let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)
            let headOffCCW = Vector3D.crossProduct(up, rhs: radStart)
        
        
            /// Vector from the start point towards the finish point
            let diff = Vector3D.built(self.start, towards: self.finish)
            
                // Can range from -1.0 to 1.0, with a gap around 0.0
            let compliesCCW = Vector3D.dotProduct(headOffCCW, rhs: diff)
        
        
            /// Value to be returned.  The initial value will be overwritten 50% of the time
            var angle = angleStock
        
            let direct = compliesCCW <= 0.0 && self.isClockwise  || compliesCCW > 0.0 && !self.isClockwise
        
            if !direct  { angle = 2.0 * M_PI - angleStock }
        
            return angle
        }
    }
    
    
    /// Define the smallest aligned rectangle that encloses the arc
    func figureExtent() -> OrthoVol  {
        
        let rad = Point3D.dist(self.ctr, pt2: self.start)
        
        var mostY = ctr.y + rad
        var mostX = ctr.x + rad
        var leastY = ctr.y - rad
        var leastX = ctr.x - rad
        
        if !self.isFull   {
            
            var chord = Vector3D.built(start, towards: finish)
            chord.normalize()
        
            let up = Vector3D(i: 0.0, j: 0.0, k: 1.0)
            var split = Vector3D.crossProduct(up, rhs: chord)
            split.normalize()
        
            var discard = split
            if self.isClockwise   { discard = split.reverse()  }
        
        
            let north = Point3D(x: ctr.x, y: mostY, z: 0.0)
            let east = Point3D(x: mostX, y: ctr.y, z: 0.0)
            let south = Point3D(x: ctr.x, y: leastY, z: 0.0)
            let west = Point3D(x: leastX, y: ctr.y, z: 0.0)
        
                // Create vectors towards the compass points
            let goNorth = Vector3D.built(start, towards: north)    // These could very well be zero length
            let goEast = Vector3D.built(start, towards: east)
            let goSouth = Vector3D.built(start, towards: south)
            let goWest = Vector3D.built(start, towards: west)
        
        
            let northDot = Vector3D.dotProduct(discard, rhs: goNorth)
            let eastDot = Vector3D.dotProduct(discard, rhs: goEast)
            let southDot = Vector3D.dotProduct(discard, rhs: goSouth)
            let westDot = Vector3D.dotProduct(discard, rhs: goWest)
        
            if northDot > 0.0   { mostY = max(start.y, finish.y) }
            if eastDot > 0.0   { mostX = max(start.x, finish.x) }
            if southDot > 0.0   { leastY = min(start.y, finish.y) }
            if westDot > 0.0   { leastX = min(start.x, finish.x) }
        }
        
        return OrthoVol(minX: leastX, maxX: mostX, minY: leastY, maxY: mostY, minZ: -1 * rad / 10.0, maxZ: rad / 10.0)
    }
    
    static func isArcable(center: Point3D, end1: Point3D, end2: Point3D) -> Bool  {
        
        let dist1 = Point3D.dist(center, pt2: end1)
        let dist2 = Point3D.dist(center, pt2: end2)
        
        let thumbsUp = (dist1 - dist2) < Point3D.Epsilon
        
        return thumbsUp
    }
    
}

/// Check to see that both are built from the same points
public func == (lhs: Arc, rhs: Arc) -> Bool   {
    
    let ctrFlag = lhs.ctr == rhs.ctr
    let startFlag = lhs.start == rhs.start
    let finishFlag = lhs.finish == rhs.finish
    
    let dirFlag = lhs.isClockwise == rhs.isClockwise
    
    return ctrFlag && startFlag && finishFlag && dirFlag    
}

