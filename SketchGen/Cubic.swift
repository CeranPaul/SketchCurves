//
//  Cubic.swift
//  SketchCurves
//
//  Created by Paul on 12/14/15.
//  Copyright © 2018 Ceran Digital Media. See LICENSE.md
//

import UIKit
import simd

// What's the right way to check for equivalence?  End points and control points?

// TODO: Will need a way to find what point, if any, has a particular slope
// TODO: Find the parameter for a point at some distance along the curve
// TODO: Add a bisecting function for Vector3D

// TODO: Clip from either end and re-parameterize.  But what about 'undo'?  Careful with a lack of proportionality


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
    
    /// The beginning point
    var ptAlpha: Point3D
    
    /// The end point
    var ptOmega: Point3D
    
    var controlA: Point3D?   // Since Bezier form is most useful for editing
    var controlB: Point3D?
    
    /// The enum that hints at the meaning of the curve
    open var usage: PenTypes
    
    open var parameterRange: ClosedRange<Double>   // Never used
    
    
    
    /// Build from 12 individual parameters.
    public init(ax: Double, bx: Double, cx: Double, dx: Double, ay: Double, by: Double, cy: Double, dy: Double, az: Double, bz: Double, cz: Double, dz: Double)   {
        
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
        
        ptAlpha = Point3D(x: dx, y: dy, z: dz)   // Create the beginning point from parameters
        
        
        let sumX = self.ax + self.bx + self.cx + self.dx   // Create the end point from parameters
        let sumY = self.ay + self.by + self.cy + self.dy
        let sumZ = self.az + self.bz + self.cz + self.dz
        
        ptOmega = Point3D(x: sumX, y: sumY, z: sumZ)
        
        
        self.usage = PenTypes.ordinary
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
    }
    
    
    /// Build from two points and two slopes
    /// This code always produces the Bezier form for ease of screen editing
    /// The assignment statements come from an algebraic manipulation of the equations
    /// in the Wikipedia article on Cubic Hermite spline
    /// - Parameters:
    ///   - ptA: First end point
    ///   - slopeA: Slope that goes with the first end point
    ///   - ptB: Other end point
    ///   - slopeB: Slope that goes with the second end point
    /// There are checks here for input points that should be added!
    /// - See: 'testSumsHermite' under CubicTests
    public init(ptA: Point3D, slopeA: Vector3D, ptB: Point3D, slopeB: Vector3D)   {
        
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
        
            // Always convert to Bezier form for editing
        var jump = slopeA * 0.3333
        self.controlA = ptAlpha.offset(jump: jump)
        
        jump = slopeB * -0.3333
        self.controlB = ptOmega.offset(jump: jump)
        
        self.usage = PenTypes.ordinary
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        parameterizeBezier()   // Generate coefficients to be recorded
        
    }
    
    
    /// Build from two end points and two control points.
    /// Assignment statements from an algebraic manipulation of the equations
    /// in the Wikipedia article on Bezier Curve.
    /// - Parameters:
    ///   - ptA: First end point
    ///   - controlA: Control point for first end
    ///   - ptB: Other end point
    ///   - controlB: Control point for second end
    /// There are checks here for input points that should be added!
    /// - See: 'testSumsBezier' under CubicTests
    public init(ptA: Point3D, controlA: Point3D, controlB: Point3D, ptB: Point3D)   {
        
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
        
        self.ptAlpha = ptA
        self.ptOmega = ptB
        
        self.controlA = controlA
        self.controlB = controlB
        
        
        
        self.usage = PenTypes.ordinary
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        parameterizeBezier()   // Generate coefficients to be recorded
        
    }
    
    /// Construct from four points that lie on the curve.  This is the way to build an offset curve.
    /// - Parameters:
    ///   - alpha: First point
    ///   - beta: Second point
    ///   - betaFraction: Portion along the curve for point beta
    ///   - gamma: Third point
    ///   - gammaFraction: Portion along the curve for point gamma
    ///   - delta: Last point
    public init(alpha: Point3D, beta: Point3D, betaFraction: Double, gamma: Point3D, gammaFraction: Double, delta: Point3D)   {
        
        self.ptAlpha = alpha
        self.ptOmega = delta
        
        // Rearrange coordinates into an array
        let rowX = double4(alpha.x, beta.x, gamma.x, delta.x)
        let rowY = double4(alpha.y, beta.y, gamma.y, delta.y)
        let rowZ = double4(alpha.z, beta.z, gamma.z, delta.z)
        
        // Build a 4x4 of parameter values to various powers
        let row1 = double4(0.0, 0.0, 0.0, 1.0)
        
        let betaFraction2 = betaFraction * betaFraction
        let row2 = double4(betaFraction * betaFraction2, betaFraction2, betaFraction, 1.0)
        
        let gammaFraction2 = gammaFraction * gammaFraction
        let row3 = double4(gammaFraction * gammaFraction2, gammaFraction2, gammaFraction, 1.0)
        
        let row4 = double4(1.0, 1.0, 1.0, 1.0)
        
        
        /// Intermediate collection for building the matrix
        var partial: [double4]
        partial = [row1, row2, row3, row4]
        
        /// Matrix of t from several points raised to various powers
        let tPowers = double4x4(partial)
        
        let trans = tPowers.transpose   // simd representation is different than what I had in college
        
        
        /// Inverse of the above matrix
        let nvers = trans.inverse
        
        let coeffX = nvers * rowX
        let coeffY = nvers * rowY
        let coeffZ = nvers * rowZ
        
        
        // Set the curve coefficients.  Do these ever get used?
        self.ax = coeffX[0]
        self.bx = coeffX[1]
        self.cx = coeffX[2]
        self.dx = coeffX[3]
        self.ay = coeffY[0]
        self.by = coeffY[1]
        self.cy = coeffY[2]
        self.dy = coeffY[3]
        self.az = coeffZ[0]
        self.bz = coeffZ[1]
        self.cz = coeffZ[2]
        self.dz = coeffZ[3]
        
        
        self.usage = PenTypes.ordinary
        
        self.parameterRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        
        // Add control points for editing
        let slopeA = self.tangentAt(t: 0.0)
        var jump = slopeA * 0.3333
        self.controlA = ptAlpha.offset(jump: jump)
        
        let slopeB = self.tangentAt(t: 1.0)
        jump = slopeB * -0.3333
        self.controlB = ptOmega.offset(jump: jump)
        
        parameterizeBezier()   // Generate coefficients to be recorded
        
    }
    
    /// Develop the coefficients from the points.
    /// This is done as a separate routine so that modifications will be consistent with original construction.
    /// Used by several initializers
    /// Should this be 'private' access level?
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
    
    
    
    /// Create a new curve translated, scaled, and rotated by the matrix.
    /// - Parameters:
    ///   - xirtam: Matrix containing translation, rotation, and scaling to be applied
    /// - See: 'testTransform' under CubicTests
    public func transform(xirtam: Transform) -> PenCurve   {
        
        let tAlpha = Point3D.transform(pip: self.ptAlpha, xirtam: xirtam)
        let tOmega = Point3D.transform(pip: self.ptOmega, xirtam: xirtam)
        
        let tControlA = Point3D.transform(pip: self.controlA!, xirtam: xirtam)
        let tControlB = Point3D.transform(pip: self.controlB!, xirtam: xirtam)
        
        let fresh = Cubic(ptA: tAlpha, controlA: tControlA, controlB: tControlB, ptB: tOmega)
        fresh.setIntent(purpose: self.usage)   // Copy setting instead of having the default
        
        return fresh
    }
    
    
    /// Attach new meaning to the curve.
    /// - See: 'testSetIntent' under CubicTests
    public func setIntent(purpose: PenTypes) -> Void  {
        self.usage = purpose
    }
    
    
    /// Fetch the location of an end.
    /// - See: 'getOtherEnd()'
    /// - See: 'testGetters' under CubicTests
    public func getOneEnd() -> Point3D   {
        return ptAlpha
    }
    
    /// Fetch the location of the opposite end.
    /// - See: 'getOneEnd()'
    /// - See: 'testGetters' under CubicTests
    public func getOtherEnd() -> Point3D   {
        return ptOmega
    }
    
    /// Flip the order of the end points (and control points).  Used to align members of a Loop.
    public func reverse() -> Void  {
        
        var bubble = self.ptAlpha
        self.ptAlpha = self.ptOmega
        self.ptOmega = bubble
        
        bubble = self.controlA!
        self.controlA! = controlB!
        controlB! = bubble
        
        parameterizeBezier()
    }
    
    
    /// Supply the point on the curve for the input parameter value.
    /// Some notations show "u" as the parameter, instead of "t"
    /// - Parameters:
    ///   - t:  Curve parameter value.  Assumed 0 < t < 1.
    /// - Returns: Point location at the parameter value
    public func pointAt(t: Double) -> Point3D   {
        
        let t2 = t * t
        let t3 = t2 * t
        
        // This notation came from "Fundamentals of Interactive Computer Graphics" by Foley and Van Dam
        // Warning!  The relationship of coefficients and powers of t might be unexpected, as notations vary
        let myX = ax * t3 + bx * t2 + cx * t + dx
        let myY = ay * t3 + by * t2 + cy * t + dy
        let myZ = az * t3 + bz * t2 + cz * t + dz
        
        return Point3D(x: myX, y: myY, z: myZ)
    }
    
    /// Differentiate to find the tangent vector for the input parameter.
    /// Some notations show "u" as the parameter, instead of "t".
    /// - Parameters:
    ///   - t:  Curve parameter value.  Assumed 0 < t < 1.
    /// - Returns:  Non-normalized vector
    func tangentAt(t: Double) -> Vector3D   {
        
        let t2 = t * t
        
        // This is the component matrix differentiated once
        let myI = 3.0 * ax * t2 + 2.0 * bx * t + cx
        let myJ = 3.0 * ay * t2 + 2.0 * by * t + cy
        let myK = 3.0 * az * t2 + 2.0 * bz * t + cz
        
        return Vector3D(i: myI, j: myJ, k: myK)    // Notice that this is not normalized!
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
    /// - See: 'testExtent' under CubicTests
    public func getExtent() -> OrthoVol   {
        
        let pieces = 15
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
            let diffs = wire.resolveRelative(speck: pip)
            
            let separation = diffs.perp.length()   // Always a positive value
            
            if separation > deviation   {
                deviation = separation
            }
            
        }
        
        return deviation
    }
    
    /// Create a plane if 21 points along the curve lie in it
    /// This doesn't handle a failed plane well.
    public func getPlane() -> Plane?   {
        
        /// Mid-point along the curve
        let mid = self.pointAt(t: 0.5)
        
        /// A plane using the end points and a midpoint
        let flat = try! Plane(alpha: self.ptAlpha, beta: mid, gamma: self.ptOmega)
        
        /// The return value
        var flag = true
        
           // Check intermediate points to that plane
        for g in 1...19   {
            
            let curT = Double(g) * 0.05
            let pip = self.pointAt(t: curT)
            
            flag = Plane.isCoincident(flat: flat, pip: pip)
            
            if !flag   {
                break
            }
        }
        
        if flag   {
            return flat
        }  else  {
            return nil
        }
    }
    
    
    /// Find the position of a point relative to the line segment and its origin.
    /// Useless result at the moment.
    /// - Parameters:
    ///   - speck:  Point near the curve.
    /// - Returns: Tuple of Vector components relative to the origin
    public func resolveRelative(speck: Point3D) -> (along: Vector3D, perp: Vector3D)   {
        
//        let otherSpeck = speck
        
        let alongVector = Vector3D(i: 1.0, j: 0.0, k: 0.0)
        
        let perpVector = Vector3D(i: 0.0, j: 1.0, k: 0.0)
        
        return (alongVector, perpVector)
    }
    
    /// Find the range of the parameter where the point is closest to the curve.
    /// What should the access level be?
    /// - Parameters:
    ///   - speck:  Target point
    ///   - span:  A range of the curve parameter t in which to hunt
    /// - Returns: A smaller ClosedRange<Double>.
    /// - See: 'testResolve' under CubicTests
    func refineRangeDist(speck: Point3D, span: ClosedRange<Double>) -> ClosedRange<Double>?   {
        
        /// Number of pieces to divide range
        let chunks = 10
        
        /// The possible return value
        var tighter: ClosedRange<Double>
        
        
        /// Parameter step
        let parStep = (span.upperBound - span.lowerBound) / Double(chunks)
        
        /// Array of equally spaced parameter values within the range.
        var params = [Double]()
        
        for g in 0...chunks   {
            let freshT = span.lowerBound + Double(g) * parStep
            params.append(freshT)
        }
        
        /// Array of separations
        let seps = params.map{ Point3D.dist(pt1: self.pointAt(t: $0), pt2: speck) }
        
        /// Smallest distance
        let close = seps.min()!
        
        /// Index of smallest distance
        let thumb = seps.index(of: close)!
        
        switch thumb   {
            
        case 0:  tighter = ClosedRange<Double>(uncheckedBounds: (lower: params[0], upper: params[1]))
            
        case seps.count - 1:  tighter = ClosedRange<Double>(uncheckedBounds: (lower: params[seps.count - 2], upper: params[seps.count - 1]))
            
        default:  tighter = ClosedRange<Double>(uncheckedBounds: (lower: params[thumb - 1], upper: params[thumb + 1]))
            
        }
        
        return tighter
    }
    
    
    /// Find the closest point on the curve
    /// - Parameters:
    ///   - speck:  Target point
    ///   - accuracy:  Optional - How close is close enough?
    /// - Returns: A nearby Point3D on the curve.
    /// - SeeAlso:  refineRangeDist()
    /// - See: 'testFindClosest' under CubicTests
    public func findClosest(speck: Point3D, accuracy: Double = Point3D.Epsilon) -> Point3D   {
        
        var priorPt = self.pointAt(t: 0.5)
        
        /// Separation between last and current iterations
        var sep = Double.greatestFiniteMagnitude
        
        var curRange = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        var tally = 0
        
        repeat   {
            
            let refinedRange = self.refineRangeDist(speck: speck, span: curRange)
            
            let midRange = ((refinedRange?.lowerBound)! + (refinedRange?.upperBound)!) / 2.0
            let midPt = self.pointAt(t: midRange)
            
            sep = Point3D.dist(pt1: priorPt, pt2: midPt)
            
            priorPt = midPt   // Set up for the next iteration
            curRange = refinedRange!
            tally += 1
            
        } while tally < 7  && sep > accuracy
        
        return priorPt
    }
    
    
    /// Find the range of the parameter where the curve crosses a line.
    /// This is part of finding the intersection.
    /// What should the access level be?
    /// Should the be rewritten as a static function to allow parallel processing?
    /// - Parameters:
    ///   - ray:  The Line to be used in testing for a crossing
    ///   - span:  A range of the curve parameter t in which to hunt
    /// - Returns: A smaller ClosedRange<Double>.
    func crossing(ray: Line, span: ClosedRange<Double>) -> ClosedRange<Double>?   {
        
        /// Number of pieces to divide range
        let chunks = 5
        
        /// The possible return value
        var tighter: ClosedRange<Double>
        
        /// Point at the beginning of the range
        let green = self.pointAt(t: span.lowerBound)
        
        /// Vector from start of Line to point at beginning of range
        let bridgeVec = Vector3D.built(from: ray.getOrigin(), towards: green)
        
        /// Components of bridge along and perpendicular to the Line
        let bridgeComps = ray.resolveRelative(arrow: bridgeVec)
        
        /// Normalized vector in the direction from the Line origin to the curve start
        var ref = bridgeComps.perp
        
        if !ref.isZero()   {
            ref.normalize()
        }
        
        /// Parameter step
        let parStep = (span.upperBound - span.lowerBound) / Double(chunks)
        
        /// Recent value of parameter
        var previousT = span.lowerBound
        
        
        for g in 1...chunks   {
            
            let freshT = span.lowerBound + Double(g) * parStep
            
            let pip = self.pointAt(t: freshT)
            
            let bridge = Vector3D.built(from: ray.getOrigin(), towards: pip)
            
            let components = ray.resolveRelative(arrow: bridge)
            
            /// Non-normalized vector in the direction from the Line origin to the current point
            let hotStuff = components.perp

            /// Length of "hotStuff" when projected to the reference vector
            let projection = Vector3D.dotProduct(lhs: hotStuff, rhs: ref)
            
            if projection < 0.0   {   // Opposite of the reference, so a crossing was just passed
                tighter = ClosedRange<Double>(uncheckedBounds: (lower: previousT, upper: freshT))
                return tighter   // Bails after the first crossing found, even if there happen to be more
            }  else  {
                previousT = freshT   // Prepare for checking the next interval
            }
        }
        
        return nil
    }
    
    /// Intersection points with a line
    /// - Parameters:
    ///   - ray:  The Line to be used for intersecting
    ///   - accuracy:  Optional - How close is close enough?
    /// - Returns: Array of points common to both curves - though for now it will return only the first one
    /// - SeeAlso:  crossing()
    /// - See: 'testIntLine1' and 'testIntLine2' under CubicTests
    public func intersect(ray: Line, accuracy: Double = Point3D.Epsilon) -> [Point3D] {
        
        /// The return array
        var crossings = [Point3D]()
        
        /// Whether or not a crossing has been found
        var crossed = false
        
        /// Separation in points for the given range of parameter t
        var sep = self.findLength()
        
        var middle = Point3D(x: -1.0, y: -1.0, z: -1.0)
        
        
        /// Interval in parameter space for hunting
        var shebang = ClosedRange<Double>(uncheckedBounds: (lower: 0.0, upper: 1.0))
        
        repeat   {
            
            if let refined = self.crossing(ray: ray, span: shebang)   {
                
                let low = self.pointAt(t: refined.lowerBound)
                let high = self.pointAt(t: refined.upperBound)
                sep = Point3D.dist(pt1: low, pt2: high)
                
                middle = Point3D.midway(alpha: low, beta: high)
                crossed = true
                shebang = refined    // Make the checked range narrower
                
            }
            
        } while crossed  &&  sep > accuracy
        
        if sep <= accuracy   {
            crossings.append(middle)
        }
        
        return crossings
    }
    
    /// Intersection points with a line
    public func intersectOld(ray: Line, accuracy: Double) -> [Point3D] {
        
        /// The return array
        var crossings = [Point3D]()
        
        
        let ref = Vector3D.built(from: ray.getOrigin(), towards: self.getOneEnd())
        
        let refComps = ray.resolveRelative(arrow: ref)
        
        /// Normalized vector in the direction from the Line origin to the curve start
        var perpOneEnd = refComps.perp
        perpOneEnd.normalize()
        
        
        /// Current step size.  Will get smaller as the search progresses
        var deltaT = 0.2
        
        /// The independent variable
        var t = -deltaT
        
        
        /// Prior value of the function
        var previous: Double
        
        /// Must start positive.  The goal is to get this to 0.0 within +/- "accuracy"
        var objective = refComps.perp.length()
        
        
        /// Backstop for the outer loop
        var outsideCount = 0   // Should this counter and check be replaced by an error call?
        
        repeat   {
            
            /// Backstop for the inner loop
            var insideCount = 0   // Should this counter and check be replaced by an error call?
            
            repeat   {
                
                t += deltaT   // Generate another value for t
                //                prevDelta = delta
                previous = objective
                
                
                let slider = self.pointAt(t: t)
                
                let cast = Vector3D.built(from: ray.getOrigin(), towards: slider)
                
                let comps = ray.resolveRelative(arrow: cast)
                
                objective = Vector3D.dotProduct(lhs: perpOneEnd, rhs: comps.perp)
                //                delta = objective - previous
                //                print(String(t) + "  " + String(objective))
                
                // Prepare for further iterations
                
                insideCount += 1
                
            } while objective * previous > 0.0 && (t + deltaT) <= 1.0  &&  insideCount < 8   // Loop until objective changes sign
            
            deltaT = deltaT / -5.0   // Decrease the step size
            //            delta *= -1.0   // Change the sign for the (previous) step, as well.
            
            outsideCount += 1
            
        } while abs(objective) > accuracy && abs(deltaT) > 0.001 && outsideCount < 10   // Iterate until a condition fails
        
        // This assumes that none of the loops have overrun
        let pip = self.pointAt(t: t)
        crossings.append(pip)
        
        print(t)
        
        return crossings
    }
    
    

    /// Plot the curve segment.  This will be called by the UIView 'drawRect' function
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    public func draw(context: CGContext, tform: CGAffineTransform) -> Void  {
        
        var xCG: CGFloat = CGFloat(self.dx)    // Convert to "CGFloat", and throw out Z coordinate
        var yCG: CGFloat = CGFloat(self.dy)
        
        let startModel = CGPoint(x: xCG, y: yCG)
        let screenStart = startModel.applying(tform)
        
        context.move(to: screenStart)
        
        
        let pieces = 20   // This really should depend on the curvature
        let step = 1.0 / Double(pieces)
        
        for g in 1...pieces   {
            
            let stepU = Double(g) * step
            xCG = CGFloat(pointAt(t: stepU).x)
            yCG = CGFloat(pointAt(t: stepU).y)
            
            let midPoint = CGPoint(x: xCG, y: yCG)
            let midScreen = midPoint.applying(tform)
            context.addLine(to: midScreen)
        }
        
        context.strokePath()
        
    }
    
    
    /// Draw symbols to be used in manipulating the curve.
    /// - Parameters:
    ///   - context: In-use graphics framework
    ///   - tform:  Model-to-display transform
    public func drawControls(context: CGContext, tform: CGAffineTransform) -> Void  {
        
        let boxDim = 8.0
        let boxSize = CGSize(width: boxDim, height: boxDim)
        
        if controlA != nil   {
            
            var xCG = CGFloat(controlA!.x)
            var yCG = CGFloat(controlA!.y)
            var leader1 = CGPoint(x: xCG, y: yCG).applying(tform)
            
            context.move(to: leader1)
            
            xCG = CGFloat(ptAlpha.x)
            yCG = CGFloat(ptAlpha.y)
            var leader2 = CGPoint(x: xCG, y: yCG).applying(tform)
            
            context.addLine(to: leader2)
            
            
            xCG = CGFloat(controlB!.x)
            yCG = CGFloat(controlB!.y)
            leader1 = CGPoint(x: xCG, y: yCG).applying(tform)
            
            context.move(to: leader1)
            
            xCG = CGFloat(ptOmega.x)
            yCG = CGFloat(ptOmega.y)
            leader2 = CGPoint(x: xCG, y: yCG).applying(tform)
            context.addLine(to: leader2)
            
            context.strokePath()
            
            // Do these last, so that the box will obscure the leader end
            xCG = CGFloat(controlA!.x)
            yCG = CGFloat(controlA!.y)
            var boxCenter = CGPoint(x: xCG, y: yCG).applying(tform)
            var boxOrigin = CGPoint(x: boxCenter.x - CGFloat(boxDim / 2.0), y: boxCenter.y - CGFloat(boxDim / 2.0))
            var controlBox = CGRect(origin: boxOrigin, size: boxSize)
            context.fill(controlBox)
            
            xCG = CGFloat(controlB!.x)
            yCG = CGFloat(controlB!.y)
            boxCenter = CGPoint(x: xCG, y: yCG).applying(tform)
            boxOrigin = CGPoint(x: boxCenter.x - CGFloat(boxDim / 2.0), y: boxCenter.y - CGFloat(boxDim / 2.0))
            controlBox = CGRect(origin: boxOrigin, size: boxSize)
            context.fill(controlBox)
            
            xCG = CGFloat(ptAlpha.x)
            yCG = CGFloat(ptAlpha.y)
            boxCenter = CGPoint(x: xCG, y: yCG).applying(tform)
            boxOrigin = CGPoint(x: boxCenter.x - CGFloat(boxDim / 2.0), y: boxCenter.y - CGFloat(boxDim / 2.0))
            controlBox = CGRect(origin: boxOrigin, size: boxSize)
            context.fill(controlBox)
            
            xCG = CGFloat(ptOmega.x)
            yCG = CGFloat(ptOmega.y)
            boxCenter = CGPoint(x: xCG, y: yCG).applying(tform)
            boxOrigin = CGPoint(x: boxCenter.x - CGFloat(boxDim / 2.0), y: boxCenter.y - CGFloat(boxDim / 2.0))
            controlBox = CGRect(origin: boxOrigin, size: boxSize)
            context.fill(controlBox)
            
        }
        
    }
    
    /// Create a String that is suitable JavaScript to draw the Cubic.
    /// Assumes that the context has a plot location of the starting point for the Cubic.
    /// - Parameters:
    ///   - xirtam:  Model-to-display transform
    /// - Returns: String consisting of JavaScript to plot
    public func jsDraw(xirtam: Transform) -> String {
        
        /// The output line
        var singleLine: String
        
        let plotCtrlA = Point3D.transform(pip: controlA!, xirtam: xirtam)
        
        let ctrlAX = Int(plotCtrlA.x + 0.5)   // The default is to round towards zero
        let ctrlAY = Int(plotCtrlA.y + 0.5)
        
        let plotCtrlB = Point3D.transform(pip: controlB!, xirtam: xirtam)
        
        let ctrlBX = Int(plotCtrlB.x + 0.5)   // The default is to round towards zero
        let ctrlBY = Int(plotCtrlB.y + 0.5)
        
        
        let plotEnd = Point3D.transform(pip: ptOmega, xirtam: xirtam)
        
        let endX = Int(plotEnd.x + 0.5)   // The default is to round towards zero
        let endY = Int(plotEnd.y + 0.5)
        
        singleLine = "ctx.bezierCurveTo(" + String(ctrlAX) + ", " + String(ctrlAY) + ", " + String(ctrlBX) + ", " + String(ctrlBY) + ", " + String(endX) + ", " + String(endY) + ");\n"
        
        return singleLine
    }
    
    
}
