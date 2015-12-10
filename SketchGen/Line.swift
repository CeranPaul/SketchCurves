//
//  Line.swift
//
//  Created by Paul on 8/12/15.
//

import Foundation

/// Unbounded
public struct Line {
    
    /// A point to locate the line
    var origin: Point3D
    
    /// Which way it extends
    var direction: Vector3D
    
    
    // Should there be an init that checks for a unit direction vector?
    init (spot: Point3D, arrow: Vector3D) throws  {
        
        self.origin = spot
        self.direction = arrow

        // Because this is an 'init', a guard statement cannot be used at the top
        if self.direction.isZero()  {throw ZeroVectorError(dir: self.direction)}
        if !self.direction.isUnit()  {throw NonUnitDirectionError(dir: self.direction)}
    }
    
    /// Checks to see if the trial point lies on the line
    public func isCoincident(trial: Point3D) -> Bool   {
        
        var bridge = Vector3D.built(self.origin, towards: trial)
        bridge.normalize()
        
        let same = bridge == self.direction
        let opp = Vector3D.isOpposite(self.direction, rhs: bridge)
        
        return same || opp
    }
    

    /// Construct a line by intersecting two planes
    /// - Throws: ParallelPlanesError if the inputs are parallel
    /// - Throws: CoincidentPlanesError if the inputs are coincident
    public static func intersectPlanes(flatA: Plane, flatB: Plane) throws -> Line   {
        
        guard !Plane.isParallel(flatA, rhs: flatB) else { throw ParallelPlanesError(enalpA: flatA, enalpB: flatB) }
            
        guard !Plane.isCoincident(flatA, rhs: flatB) else { throw CoincidentPlanesError(enalpA: flatA) }
        
        /// Direction of the intersection line
        var lineDir = Vector3D.crossProduct(flatA.normal, rhs: flatB.normal)
        lineDir.normalize()
        
        /// Vector on plane B that is perpendicular to the intersection line
        var perpInB = Vector3D.crossProduct(lineDir, rhs: flatB.normal)
        perpInB.normalize()
        
          // The ParallelPlanesError or CoincidentPlanesError should be avoided by the guard statements
            
        let lineFromCenterB =  try Line(spot: flatB.location, arrow: perpInB)  // Can be either towards flatA,
                                                                                   // or away from it
            
        let intersectionPoint = try Point3D.intersectLinePlane(lineFromCenterB, enalp: flatA)
        let common = try Line(spot: intersectionPoint, arrow: lineDir)
        
        return common
    }
    
}


/// Check to see that the second origin lies on the first Line, and that
///  the directions are identical  Opposite direction will fail this test
public func == (lhs: Line, rhs: Line) -> Bool   {
    
    let flag1 = lhs.isCoincident(rhs.origin)
    
    let flag2 = lhs.direction == rhs.direction
    
    return flag1 && flag2    
}

