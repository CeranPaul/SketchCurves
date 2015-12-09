//
//  Line.swift
//  CornerTri
//
//  Created by Paul on 8/12/15.
//

import Foundation

struct Line {
    
    var origin: Point3D
    var direction: Vector3D
    
    // Should there be an init that checks for a unit direction vector?
    
    
    /// Checks to see if the trial point lies on the line
    func isCoincident(trial: Point3D) -> Bool   {
        
        var bridge = Vector3D.built(self.origin, towards: trial)
        bridge.normalize()
        
        let same = bridge == self.direction
        let opp = Vector3D.isOpposite(self.direction, rhs: bridge)
        
        return same || opp
    }

    /// Construct a line by intersecting two planes
    /// - Throws: ParallelPlanesError if the inputs are parallel
    /// - Throws: CoincidentPlanesError if the inputs are coincident
    static func intersectPlanes(flatA: Plane, flatB: Plane) throws -> Line   {
        
        guard !Plane.isParallel(flatA, rhs: flatB) else { throw ParallelPlanesError(enalpA: flatA, enalpB: flatB) }
            
        guard !Plane.isCoincident(flatA, rhs: flatB) else { throw CoincidentPlanesError(enalpA: flatA, enalpB: flatB) }
        
        
        var lineDir = Vector3D.crossProduct(flatA.normal, rhs: flatB.normal)
        lineDir.normalize()
        
        
        var perpInB = Vector3D.crossProduct(lineDir, rhs: flatB.normal)
        perpInB.normalize()
        
        let lineFromCenterB = Line(origin: flatB.location, direction: perpInB)  // Can be either towards flatA,
                                                                                // or away from it
        
        do    {     // This possible error should have been avoided by the check for parallel planes in the guard statement
            
            let intersectionPoint = try Point3D.intersectLinePlane(lineFromCenterB, enalp: flatA)

            return Line(origin: intersectionPoint, direction: lineDir)
        }
        
//        catch let error as ParallelError   {
            
//            print(error.description)
            
//            let intersectionPoint = Point3D(x: 0.0, y: 0.0, z: 0.0)
//            return Line(origin: intersectionPoint, direction: lineDir)
//        }
        
        catch  {   // This is actually useless, and should go away
            
            print("Unexpected error while intersecting planes")
            
            let intersectionPoint = Point3D(x: 0.0, y: 0.0, z: 0.0)
            return Line(origin: intersectionPoint, direction: lineDir)
        }
        
    }
    
}
