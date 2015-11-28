//
//  OrthoVol.swift
//  CurveLab
//
//  Created by Paul on 10/30/15.
//

import Foundation

/// A 'brick' aligned with the coordinate axes that envelops a curve.  Useful for scaling and intersections.
public struct OrthoVol   {
    
    private var origin: Point3D
    
    private var width: Double    // These are assumed to be always positive
    private var height: Double
    private var depth: Double
    
    
    /// Rudimentary init
    public init(minX : Double, maxX: Double, minY: Double, maxY: Double, minZ: Double, maxZ: Double)   {
        
        let deltaX = maxX - minX
        let skinnyX = (deltaX == 0)
        
        let deltaY = maxY - minY
        let skinnyY = (deltaY == 0)
        
        let deltaZ = maxZ - minZ
        let skinnyZ = (deltaZ == 0)
        
        var smallX = minX
        width = deltaX
        
        var smallY = minY
        height = deltaY

        var smallZ = minZ
        depth = deltaZ

       
        if skinnyX || skinnyY || skinnyZ   {  // One of the sizes = 0.0
            
            let sep = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
            let halfMin = sep / 10.0   // Used to keep the box from becoming a whisker
            
            if skinnyX   {
                smallX = minX - halfMin
                width = 2 * halfMin
            }  else if deltaX < 0.0 {
                smallX = maxX
                width = abs(deltaX)
            }
            
            if skinnyY   {
                smallY = minY - halfMin
                height = 2 * halfMin
            }  else if deltaY < 0.0 {
                smallY = maxY
                height = abs(deltaY)
            }
            
            if skinnyZ   {
                smallZ = minZ - halfMin
                depth = 2 * halfMin
            }  else if deltaZ < 0.0 {
                smallZ = maxZ
                depth = abs(deltaZ)
            }
            
           
        }  else  {    // No sizes of 0.0
            
            if deltaX < 0.0 {
                smallX = maxX
                width = abs(deltaX)
            }
            
            if deltaY < 0.0 {
                smallY = maxY
                height = abs(deltaY)
            }
            
            if deltaZ < 0.0 {
                smallZ = maxZ
                depth = abs(deltaZ)
            }
            
        }
        
        
        self.origin = Point3D(x: smallX, y: smallY, z: smallZ)
        
    }
    
    /// Build a brick from two points
    /// Will prevent having a zero dimension for any of the three axes  But needs to adda check for coincident points
    public init(corner1: Point3D, corner2: Point3D) throws  {
        
        let sep = Point3D.dist(corner1, pt2: corner2)
        let halfMin = sep / 10.0   // Used to keep the box from becoming a whisker
        
        var leastX: Double
        var mostX: Double
        
        if corner1.x == corner2.x   {
            leastX = corner1.x - halfMin
            mostX = corner1.x + halfMin
        } else {
            leastX = min(corner1.x, corner2.x)
            mostX = max(corner1.x, corner2.x)
        }
        
        var leastY: Double
        var mostY: Double
        
        if corner1.y == corner2.y   {
            leastY = corner1.y - halfMin
            mostY = corner1.y + halfMin
        } else {
            leastY = min(corner1.y, corner2.y)
            mostY = max(corner1.y, corner2.y)
        }
        
        var leastZ: Double
        var mostZ: Double
        
        if corner1.z == corner2.z   {
            leastZ = corner1.z - halfMin
            mostZ = corner1.z + halfMin
        } else {
            leastZ = min(corner1.z, corner2.z)
            mostZ = max(corner1.z, corner2.z)
        }
        
        self.origin = Point3D(x: leastX, y: leastY, z: leastZ)
        
        self.width = mostX - leastX
        self.height = mostY - leastY
        self.depth = mostZ - leastZ
        
        // Because this is an 'init', a guard statement cannot be used at the top
        if corner1 == corner2 { throw CoincidentPointsError(dupePt: corner1) }
        
    }
    
    
    /// Simple getter
    func  getOrigin() -> Point3D  {
        return self.origin
    }
    
    func  getWidth() -> Double  {
        return self.width
    }
    
    func  getHeight() -> Double  {
        return self.height
    }
    
    func  getDepth() -> Double  {
        return self.depth
    }
    
}

/// Construct a volume that contains the two input volumes
func + (lhs: OrthoVol, rhs: OrthoVol) -> OrthoVol   {
    
    let leastX = min(lhs.origin.x, rhs.origin.x)
    let mostX = max(lhs.origin.x + lhs.width, rhs.origin.x + rhs.width)
    
    let leastY = min(lhs.origin.y, rhs.origin.y)
    let mostY = max(lhs.origin.y + lhs.height, rhs.origin.y + rhs.height)
    
    let leastZ = min(lhs.origin.z, rhs.origin.z)
    let mostZ = max(lhs.origin.z + lhs.depth, rhs.origin.z + rhs.depth)

    let combined = OrthoVol(minX: leastX, maxX: mostX, minY: leastY, maxY: mostY, minZ: leastZ, maxZ: mostZ)
    return combined
}


