//
//  Cubic.swift
//  SketchCurves
//
//  Created by Paul on 12/14/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

/// Curve defined by polynomials for each coordinate direction
open class Cubic: PenCurve   {
    
    var ax: Double
    var bx: Double
    var cx: Double
    var dx: Double
    
    var ay: Double
    var by: Double
    var cy: Double
    var dy: Double
    
    var az: Double   // For a curve in the XY plane, these can be ignored, or set to zero
    var bz: Double
    var cz: Double
    var dz: Double
    
    var ptAlpha: Point3D
    var ptOmega: Point3D
    
    var controlA: Point3D?
    var controlB: Point3D?
    
    /// The enum that hints at the meaning of the curve
    public var usage: PenTypes
    
    /// The box that contains the segment
    public var extent: OrthoVol
    
    
    
    /// Build from 12 individual parameters
    init (ax: Double, bx: Double, cx: Double, dx: Double, ay: Double, by: Double, cy: Double, dy: Double, az: Double, bz: Double, cz: Double, dz: Double)   {
        
        self.ax = ax
        self.bx = bx
        self.cx = cx
        self.dx = dx
        
        self.ay = ay
        self.by = by
        self.cy = cy
        self.dy = dy
        
        self.az = az
        self.bz = bz
        self.cz = cz
        self.dz = dz
        
        ptAlpha = Point3D(x: dx, y: dy, z: dz)
        
        let sumX = self.ax + self.bx + self.cx + self.dx
        let sumY = self.ay + self.by + self.cy + self.dy
        let sumZ = self.az + self.bz + self.cz + self.dz
        
        ptOmega = Point3D(x: sumX, y: sumY, z: sumZ)
        
        
        self.usage = PenTypes.ordinary
        
        // Dummy assignment. Postpone the expensive calculation until after the guard statements
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        self.extent = self.getExtent()
        
    }
    
    /// Build from two points and two slopes
    /// The assignment statements come from an algebraic manipulation of the equations
    /// in the Wikipedia article on Cubic Hermite spline
    /// There are checks here for input points that should be added!
    /// - See: 'testSumsHermite' under CubicTests
    init(ptA: Point3D, slopeA: Vector3D, ptB: Point3D, slopeB: Vector3D)   {
        
        ptAlpha = ptA
        ptOmega = ptB
        
        self.ax = 2.0 * ptA.x + slopeA.i - 2.0 * ptB.x + slopeB.i
        self.bx = -3.0 * ptA.x - 2.0 * slopeA.i + 3.0 * ptB.x - slopeB.i
        self.cx = slopeA.i
        self.dx = ptA.x
        
        self.ay = 2.0 * ptA.y + slopeA.j - 2.0 * ptB.y + slopeB.j
        self.by = -3.0 * ptA.y - 2.0 * slopeA.j + 3.0 * ptB.y - slopeB.j
        self.cy = slopeA.j
        self.dy = ptA.y
        
        self.az = 2.0 * ptA.z + slopeA.k - 2.0 * ptB.z + slopeB.k
        self.bz = -3.0 * ptA.z - 2.0 * slopeA.k + 3.0 * ptB.z - slopeB.k
        self.cz = slopeA.k
        self.dz = ptA.z
        
        self.usage = PenTypes.ordinary
        
        // Dummy assignment. Postpone the expensive calculation until after the guard statements
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        self.extent = self.getExtent()
        
    }
    
    
    /// Build from two end points and two control points
    /// Assignment statements from an algebraic manipulation of the equations
    /// in the Wikipedia article on Bezier Curve
    /// There are checks here for input points that should be added!
    /// - See: 'testSumsBezier' under CubicTests
    init(ptA: Point3D, controlA: Point3D, controlB: Point3D, ptB: Point3D)   {
        
        self.usage = PenTypes.ordinary
        
           // Dummy initial values
        self.ax = 0.0
        self.bx = 0.0
        self.cx = 0.0
        self.dx = 0.0
        
        self.ay = 0.0
        self.by = 0.0
        self.cy = 0.0
        self.dy = 0.0
        
        self.az = 0.0
        self.bz = 0.0
        self.cz = 0.0
        self.dz = 0.0
        
        // Dummy assignment. Postpone the expensive calculation until after the guard statements
        self.extent = OrthoVol(minX: -0.5, maxX: 0.5, minY: -0.5, maxY: 0.5, minZ: -0.5, maxZ: 0.5)
        
        self.ptAlpha = ptA
        self.ptOmega = ptB
        
        self.controlA = controlA
        self.controlB = controlB
        
        parameterizeBezier()   // Generate the real coefficients
        
        self.extent = self.getExtent()
        
    }
    
    /// Develop the coefficients from the points
    /// This is done as a separate routine so that modifications will be consistent with original construction
    func parameterizeBezier() -> Void {
        
        self.ax = 3.0 * self.controlA!.x - self.ptAlpha.x - 3.0 * self.controlB!.x + self.ptOmega.x
        self.bx = 3.0 * self.ptAlpha.x - 6.0 * self.controlA!.x + 3.0 * self.controlB!.x
        self.cx = 3.0 * self.controlA!.x - 3.0 * self.ptAlpha.x
        self.dx = self.ptAlpha.x
        
        self.ay = 3.0 * self.controlA!.y - self.ptAlpha.y - 3.0 * self.controlB!.y + self.ptOmega.y
        self.by = 3.0 * self.ptAlpha.y - 6.0 * self.controlA!.y + 3.0 * self.controlB!.y
        self.cy = 3.0 * self.controlA!.y - 3.0 * self.ptAlpha.y
        self.dy = self.ptAlpha.y
        
        self.az = 3.0 * self.controlA!.z - self.ptAlpha.z - 3.0 * self.controlB!.z + self.ptOmega.z
        self.bz = 3.0 * self.ptAlpha.z - 6.0 * self.controlA!.z + 3.0 * self.controlB!.z
        self.cz = 3.0 * self.controlA!.z - 3.0 * self.ptAlpha.z
        self.dz = self.ptAlpha.z
    }
    
    /// Attach new meaning to the curve
    public func setIntent(purpose: PenTypes)   {
        
        self.usage = purpose
    }
    
    /// Fetch the location of an end
    /// - See: 'getOtherEnd()'
    public func getOneEnd() -> Point3D   {
        return ptAlpha
    }
    
    /// Fetch the location of the opposite end
    /// - See: 'getOneEnd()'
    public func getOtherEnd() -> Point3D   {
        return ptOmega
    }
    
    /// Flip the order of the end points (and control points).  Used to align members of a Perimeter
    public func reverse() -> Void  {
        
        var bubble = self.ptAlpha
        self.ptAlpha = self.ptOmega
        self.ptOmega = bubble
        
        bubble = self.controlA!
        self.controlA! = controlB!
        controlB! = bubble
        
        parameterizeBezier()
    }
    
    
    /// Tweak the curve by changing one control point
    /// - Parameters:
    ///   - deltaX: Location change in X direction
    ///   - deltaY: Location change in Y direction
    ///   - deltaZ: Location change in Z direction
    ///   - modA: Selector for which control point gets modified
    public func modifyControlPoint(deltaX: Double, deltaY: Double, deltaZ: Double, modA: Bool) -> Void   {
        
        if modA   {
            
            self.controlA!.x += deltaX
            self.controlA!.y += deltaY
            self.controlA!.z += deltaZ
            
        }  else  {
            
            self.controlB!.x += deltaX
            self.controlB!.y += deltaY
            self.controlB!.z += deltaZ
            
        }
        
        parameterizeBezier()
    }
    
    /// Tweak a Bezier curve by changing an end point
    /// - Parameters:
    ///   - deltaX: Location change in X direction
    ///   - deltaY: Location change in Y direction
    ///   - deltaZ: Location change in Z direction
    ///   - modAlpha: Selector for which control point gets modified
    public func modifyEndPoint(deltaX: Double, deltaY: Double, deltaZ: Double, modAlpha: Bool) -> Void   {
        
        if modAlpha   {
            
            self.ptAlpha.x += deltaX
            self.ptAlpha.y += deltaY
            self.ptAlpha.z += deltaZ
            
        }  else  {
            
            self.ptOmega.x += deltaX
            self.ptOmega.y += deltaY
            self.ptOmega.z += deltaZ
            
        }
        
        parameterizeBezier()
    }
    
    
    /// Break into pieces and sum up the distances
    /// - Returns: Double that is an approximate length
    public func findLength() -> Double   {
        
        let pieces = 20
        let step = 1.0 / Double(pieces)
        let limit = pieces
        
        var prevPoint = self.pointAt(t: 0.0)
        
        var length = 0.0
        
        for g in 1...limit   {
            
            let pip = self.pointAt(t: Double(g) * step)
            let hop = Point3D.dist(pt1: prevPoint, pt2: pip)
            length += hop
            
            prevPoint = pip
        }
        
        return length
    }
    
    /// Calculate the proper surrounding box
    /// Increase the number of intermediate points as necessary
    public func getExtent() -> OrthoVol   {
        
        let pieces = 10
        let step = 1.0 / Double(pieces)
        let limit = pieces - 1
        
        var bucket = [Double]()
        
        for u in 1...limit   {
            let pip = self.pointAt(t: Double(u) * step)
            bucket.append(pip.x)
        }
        
        bucket.append(ptOmega.x)
        
        let maxX = bucket.reduce(ptAlpha.x, max)
        let minX = bucket.reduce(ptAlpha.x, min)
        
        
        bucket = [Double]()   // Start with an empty array
        
        for u in 1...limit   {
            let pip = self.pointAt(t: Double(u) * step)
            bucket.append(pip.y)
        }
        
        bucket.append(ptOmega.y)
        
        let maxY = bucket.reduce(ptAlpha.y, max)
        let minY = bucket.reduce(ptAlpha.y, min)
        
        bucket = [Double]()   // Start with an empty array
        
        for u in 1...limit   {
            let pip = self.pointAt(t: Double(u) * step)
            bucket.append(pip.z)
        }
        
        bucket.append(ptOmega.z)
        
        var maxZ = bucket.reduce(ptAlpha.z, max)
        var minZ = bucket.reduce(ptAlpha.z, min)
        
        
        // Avoid the case of zero thickness
        let diffX = maxX - minX
        let diffY = maxY - minY
        let diffZ = maxZ - minZ
        
        let bigDiff = max(diffX, diffY)
        let percent = 0.01 * bigDiff
        
        if abs(diffZ) < percent   {
            maxZ += 0.5 * percent
            minZ -= 0.5 * percent
        }
        
        
        let box = OrthoVol(minX: minX, maxX: maxX, minY: minY, maxY: maxY, minZ: minZ, maxZ: maxZ)
        
        return box
    }
    
    
    /// Find the change in parameter that meets the crown requirement
    /// - Parameters:
    ///   - allowableCrown:  Acceptable deviation from curve
    ///   - currentT:  Present value of the driving parameter
    ///   - increasing:  Whether the change in parameter should be up or down
    /// - Returns: New value for driving parameter
    public func findStep(allowableCrown: Double, currentT: Double, increasing: Bool) -> Double   {
        
        var trialT: Double
        var deviation: Double
        var step = 0.2 * 1.25  // Wild guess for original case
        
        /// Counter to prevent loop runaway
        var safety = 0
        
        repeat   {
            
            step = step / 1.25
            
            if increasing   {
                
                trialT = currentT + step
                if currentT > (1.0 - step)   {   // Prevent parameter value > 1.0
                    trialT = 1.0
                }
                
                deviation = self.findCrown(smallerT: currentT, largerT: trialT)
                
            }  else {
                
                trialT = currentT - step
                if currentT < step   {   // Prevent parameter value < 0.0
                    trialT = 0.0
                }
                deviation = self.findCrown(smallerT: trialT, largerT: currentT)
            }
            
            safety += 1
            
        }  while deviation > allowableCrown  && safety < 9
        
        return trialT
    }
    
    /// Calculate the crown over a small segment
    public func findCrown(smallerT: Double, largerT: Double) -> Double   {
        
        let anchorA = self.pointAt(t: smallerT)
        let anchorB = self.pointAt(t: largerT)
        
        let wire = try! LineSeg(end1: anchorA, end2: anchorB)
        
        let delta = largerT - smallerT
        
        var deviation = 0.0
        
        for g in 1...9   {
            
            let pip = self.pointAt(t: smallerT + Double(g) * delta / 10.0)
            let diffs = wire.resolveNeighbor(speck: pip)
            
            let separation = diffs.perp.length()   // Always a positive value
            
            if separation > deviation   {
                deviation = separation
            }
            
        }
        
        return deviation
    }
    
    /// Supply the point on the curve for the input parameter value
    /// Some notations show "t" as the parameter, instead of "u"
    public func pointAt(t: Double) -> Point3D   {
        
        let t2 = t * t
        let t3 = t2 * t
        
           // This notation came from "Fundamentals of Interactive Computer Graphics" by Foley and Van Dam
           // Warning!  The relationship of coefficients and powers of u might be unexpected, as notations vary
        let myX = ax * t3 + bx * t2 + cx * t + dx
        let myY = ay * t3 + by * t2 + cy * t + dy
        let myZ = az * t3 + bz * t2 + cz * t + dz
        
        return Point3D(x: myX, y: myY, z: myZ)
    }
    
    /// Differentiate to find the tangent vector for the input parameter
    /// Some notations show "t" as the parameter, instead of "u"
    /// - Returns:
    ///   - tan:  Non-normalized vector
    func tangentAt(t: Double) -> Vector3D   {
        
        let t2 = t * t

        let myI = 3.0 * ax * t2 + 2.0 * bx * t + cx
        let myJ = 3.0 * ay * t2 + 2.0 * by * t + cy
        let myK = 3.0 * az * t2 + 2.0 * bz * t + cz
        
        return Vector3D(i: myI, j: myJ, k: myK)    // Notice that this is not normalized!
    }
    
    
    /// Find the position of a point relative to the line segment and its origin
    /// - Returns: Vector components relative to the origin
    public func resolveNeighbor(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
//        let otherSpeck = speck
        
        let alongVector = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let perpVector = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        return (alongVector, perpVector)
    }
    
    
    
    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    public func draw(context: CGContext, tform: CGAffineTransform)  {
        
        var xCG: CGFloat = CGFloat(self.dx)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.dy)
        
        let startModel = CGPoint(x: xCG, y: yCG)
        let screenStart = startModel.applying(tform)
        
        context.move(to: screenStart)
        
        
        for g in 1...20   {
            
            let stepU = Double(g) * 0.05   // Gee, this is brittle!
            xCG = CGFloat(pointAt(t: stepU).x)
            yCG = CGFloat(pointAt(t: stepU).y)
            //            print(String(describing: xCG) + "  " + String(describing: yCG))
            let midPoint = CGPoint(x: xCG, y: yCG)
            let midScreen = midPoint.applying(tform)
            context.addLine(to: midScreen)
        }
        
        context.strokePath()
        
    }
    
    // What's the right way to check for equivalence?
    
    // TODO: Figure a way to do an offset curve
    
}
