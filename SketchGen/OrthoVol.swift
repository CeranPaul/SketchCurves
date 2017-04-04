//
//  OrthoVol.swift
//  SketchCurves
//
//  Created by Paul on 10/30/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import Foundation

/// A 'brick' aligned with the coordinate axes to envelop some geometry.  Useful for scaling and intersections.
/// Does not allow 0.0 thicknesses
public struct OrthoVol   {
    
    fileprivate var rangeX: ClosedRange<Double>
    fileprivate var rangeY: ClosedRange<Double>
    fileprivate var rangeZ: ClosedRange<Double>
    
    
    /// Rudimentary init
    /// Does not check for positive ranges
    public init(minX : Double, maxX: Double, minY: Double, maxY: Double, minZ: Double, maxZ: Double)   {
        
        let deltaX = maxX - minX
        
        if deltaX < 0.0 {   // Reverse the ordering, if necessary
            rangeX = ClosedRange(uncheckedBounds: (lower: maxX, upper: minX))
        }  else  {
            rangeX = ClosedRange(uncheckedBounds: (lower: minX, upper: maxX))
        }
        
        let skinnyX = (deltaX == 0)
        
        
        let deltaY = maxY - minY
        
        if deltaY < 0.0 {
            rangeY = ClosedRange(uncheckedBounds: (lower: maxY, upper: minY))
        }  else  {
            rangeY = ClosedRange(uncheckedBounds: (lower: minY, upper: maxY))
        }
        
        let skinnyY = (deltaY == 0)
        
        
        let deltaZ = maxZ - minZ
        
        if deltaZ < 0.0 {
            rangeZ = ClosedRange(uncheckedBounds: (lower: maxZ, upper: minZ))
        }  else  {
            rangeZ = ClosedRange(uncheckedBounds: (lower: minZ, upper: maxZ))
        }
        
        let skinnyZ = (deltaZ == 0)

       
        if skinnyX || skinnyY || skinnyZ   {  // One or more of the sizes = 0.0
            
            let sep = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
            let halfMin = sep / 10.0   // Used to keep the box from becoming a whisker
            
            if skinnyX   {
                rangeX = ClosedRange(uncheckedBounds: (lower: minX - halfMin, upper: minX + halfMin))
            }
            
            if skinnyY   {
                rangeY = ClosedRange(uncheckedBounds: (lower: minY - halfMin, upper: minY + halfMin))
            }
            
            if skinnyZ   {
                rangeZ = ClosedRange(uncheckedBounds: (lower: minZ - halfMin, upper: minZ + halfMin))
            }
        }
        
    }
    
    /// Build a brick from two points
    /// Will prevent having a zero dimension for any of the three axes  
    /// - Throws: CoincidentPointsError
    public init(corner1: Point3D, corner2: Point3D) throws  {
        
        let sep = Point3D.dist(pt1: corner1, pt2: corner2)
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
                
        
        rangeX = ClosedRange(uncheckedBounds: (lower: leastX, upper: mostX))
        rangeY = ClosedRange(uncheckedBounds: (lower: leastY, upper: mostY))
        rangeZ = ClosedRange(uncheckedBounds: (lower: leastZ, upper: mostZ))
        
        // Because this is an 'init', a guard statement cannot be used at the top
        if corner1 == corner2 { throw CoincidentPointsError(dupePt: corner1)}
        
    }
    
    
    /// Simple getter for starting corner
    func  getOrigin() -> Point3D  {
        return Point3D(x: rangeX.lowerBound, y: rangeY.lowerBound, z: rangeZ.lowerBound)
    }
    
    /// Simple getter for the width
    func  getWidth() -> Double  {
        return rangeX.upperBound - rangeX.lowerBound
    }
    
    /// Simple getter for the height
    func  getHeight() -> Double  {
        return rangeY.upperBound - rangeY.lowerBound
    }
    
    /// Simple getter for the depth
    func  getDepth() -> Double  {
        return rangeZ.upperBound - rangeZ.lowerBound
    }
    
    /// See whether the two volumes overlap
    public static func isOverlapping(lhs: OrthoVol, rhs: OrthoVol) -> Bool   {
        
        let flagX = lhs.rangeX.overlaps(rhs.rangeX)
        let flagY = lhs.rangeY.overlaps(rhs.rangeY)
        let flagZ = lhs.rangeZ.overlaps(rhs.rangeZ)
        
        return flagX && flagY && flagZ
    }
    
    
}   // End of definition for struct OrthoVol


/// Construct a volume that combines the two input volumes
func + (lhs: OrthoVol, rhs: OrthoVol) -> OrthoVol   {
    
    let leastX = min(lhs.rangeX.lowerBound, rhs.rangeX.lowerBound)
    let mostX = max(lhs.rangeX.upperBound, rhs.rangeX.upperBound)
    
    let leastY = min(lhs.rangeY.lowerBound, rhs.rangeY.lowerBound)
    let mostY = max(lhs.rangeY.upperBound, rhs.rangeY.upperBound)
    
    let leastZ = min(lhs.rangeZ.lowerBound, rhs.rangeZ.lowerBound)
    let mostZ = max(lhs.rangeZ.upperBound, rhs.rangeZ.upperBound)

    let combined = OrthoVol(minX: leastX, maxX: mostX, minY: leastY, maxY: mostY, minZ: leastZ, maxZ: mostZ)
    
    return combined
}




