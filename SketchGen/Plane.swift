//
//  Plane.swift
//  CornerTri
//
//  Created by Paul on 8/11/15.
//

import Foundation

public struct Plane   {
    
    /// A point to locate the plane
    var location: Point3D
    
    /// A vector perpendicular to the plane
    var normal: Vector3D
    
    
    
    /// Check to see that the line direction is perpendicular to the normal
    func isParallel(enil: Line) -> Bool   {
        
        let perp = Vector3D.dotProduct(enil.direction, rhs: self.normal)
        
        return abs(perp) < Vector3D.EpsilonV
    }
    
    /// Check to see that the line is parallel to the plane, and lies on it
    func isCoincident(enil: Line) -> Bool  {
        
        return self.isParallel(enil) && Plane.isCoincident(self, pip: enil.origin)
    }
    
    
    func equals(rhs: Plane) -> Bool   {
        
        let flag1 = self.normal == rhs.normal
        let flag2 = self.location == rhs.location
        
        return flag1 && flag2
    }
    
    
    /// Check to see if the argument point lies on the plane
    static func isCoincident(flat: Plane, pip:  Point3D) -> Bool  {
        
        let bridge = Vector3D.built(flat.location, towards: pip)
        
        // This can be positive, negative, or zero
        let distanceOffPlane = Vector3D.dotProduct(bridge, rhs: flat.normal)  // FIXME:  Deal with coincident points
        
        return  abs(distanceOffPlane) < Point3D.Epsilon
    }
    
    /// Normals are parallel or opposite
    static func isParallel(lhs: Plane, rhs: Plane) -> Bool{
        
        return lhs.normal == rhs.normal || Vector3D.isOpposite(lhs.normal, rhs: rhs.normal)
    }
    
    /// Planes are parallel, and rhs location lies on lhs
    static func isCoincident(lhs: Plane, rhs: Plane) -> Bool  {
        
        return Plane.isParallel(lhs, rhs: rhs) && Plane.isCoincident(lhs, pip: rhs.location)
    }
    
    
    static func buildParallel(base: Plane, offset: Double, reverse: Bool) -> Plane  {
    
        let jump = base.normal * offset    // offset can be a negative number
        
        let origPoint = base.location
        let newLoc = origPoint.offset(jump)
        
        
        var newNorm = base.normal
        
        if reverse   {
            newNorm = base.normal * -1.0
        }
        
        let sparkle = Plane(location: newLoc, normal: newNorm)
    
        return sparkle
    }
    
    static func buildPerpThruLine(enil:  Line, enalp: Plane)  -> Plane   {
        
        let newDir = Vector3D.crossProduct(enil.direction, rhs: enalp.normal)
        
        return Plane(location: enil.origin, normal: newDir)
    }
    
    /// Generate planes to approximate a corner between two input planes
    /// - Parameter: radius: Radius of the corner
    /// - Parameter: maxCrown: Largest allowable gap of the approximation
    /// - Throws: ParallelPlanesError upon bad inputs
    /// - Throws: CoincidentPlanesError also for bad inputs
    static func genCorner(alpha: Plane, beta: Plane, radius: Double, maxCrown: Double, inside: Bool) throws -> [Plane]   {
        
        guard !isParallel(alpha, rhs: beta) else { throw ParallelPlanesError(enalpA: alpha, enalpB: beta) }

        guard !Plane.isCoincident(alpha, rhs: beta) else { throw CoincidentPlanesError(enalpA: alpha, enalpB: beta) }
        
            // Adjust the offset for whether this is an inside or outside corner
        var off = radius
        if !inside  { off = -1.0 * radius }
        
            // Offset the planes
        let offsetA = Plane.buildParallel(alpha, offset: off, reverse: !inside)
        let offsetB = Plane.buildParallel(beta, offset: off, reverse: !inside)
        
        
        /// Centerline of the cylinder
        let cornerCenterline = try Line.intersectPlanes(offsetA, flatB: offsetB)
        
        /// Will consist of the first trim plane, a variable number of slender planes, each followed by its trim plane,
        ///  though the final slender plane is followed by a trim plane at the tangent line.
        var resultPlanes = Array<Plane>()   // The array to be returned
        
        let trimAlpha = Plane.buildPerpThruLine(cornerCenterline, enalp: alpha)
        resultPlanes.append(trimAlpha)
        
        let trimBeta = Plane.buildPerpThruLine(cornerCenterline, enalp: beta)
        // This will be added to the end of the array at the end of the func
        
        
        
        // Figure how many planes are needed to represent the fillet
        let dotAB = Vector3D.dotProduct(alpha.normal, rhs: beta.normal)
        
        let angleRad = acos(dotAB)
        
        let arg = (radius - maxCrown) / radius
        let theta = acos(arg)
        let divisions = ceil(angleRad / theta)
        let stepAngle = angleRad / divisions
        
        let divs = Int(divisions)
        
//        print(divs)
        
        // Generate a 'mid' point of the fillet centerline
        //        let midCL = Point3D(x: filletCenterline.origin.x, y: filletCenterline.origin.y, z: 0.0)   // Brittle!
        let midCL = cornerCenterline.origin
        
        // Create a 'mid' point on the tangency line
        let tangency = try Line.intersectPlanes(alpha, flatB: trimAlpha)
        
        //        var priorMid = Point3D(x: tangency.origin.x, y: tangency.origin.y, z: 0.0)   // Brittle!
        var priorMid = tangency.origin
        
        
        let radialStart = alpha.normal.reverse()  // From the CL outwards
        
        // Generate the face planes and their trim planes
        
        for var i = 1; i <= divs; i++    {
            
            // Twist a vector
            let steppedRadialVector = radialStart.twistAbout(cornerCenterline.direction, angleRad: stepAngle * Double(i))
            
            var radialOffset = steppedRadialVector * radius
            if !inside  { radialOffset = steppedRadialVector * -1.0 * radius }
            
            let stepCenter = midCL.offset(radialOffset)
            
            // Generate a midpoint and then the plane
            let skinnyCenter = Point3D.midway(priorMid, beta: stepCenter)
            let chord = Vector3D.built(priorMid, towards: stepCenter)
            let skinnyNorm = Vector3D.crossProduct(cornerCenterline.direction, rhs: chord)
            
            let skinny = Plane(location: skinnyCenter, normal: skinnyNorm)
            resultPlanes.append(skinny)
            
            
            if i != divs   {
                
                // Build a plane to trim that skinny section
                let trimNorm = Vector3D.crossProduct(cornerCenterline.direction, rhs: steppedRadialVector)
                
                let tStep = steppedRadialVector * (radius / 2.0)
                let trimCenter = midCL.offset(tStep)
                
                let skinnyTrim = Plane(location: trimCenter, normal: trimNorm)
                resultPlanes.append(skinnyTrim)
                
                priorMid = stepCenter   // Bump references for the next iteration
            }
            
        }   // End of loop to generate planes
        
        resultPlanes.append(trimBeta)
        
        return resultPlanes
    }
}