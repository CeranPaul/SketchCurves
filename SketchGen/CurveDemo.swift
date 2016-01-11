//
//  Roundy.swift
//  BoxChopDemo
//
//  Created by Paul Hollingshead on 11/8/15.
//  Copyright © 2015 Ceran Digital Media. All rights reserved.
//

import Foundation

var modelGeo = Roundy()

class Roundy  {
    
    /// The display list, since this program uses only line segments
    var displayLines: [PenCurve]
    
    /// Points used to terminate the segments in "displayLines"
    var displayPoints: [Point3D]
    
    /// Rectangle encompassing all of the curves to be displayed
    var extent: OrthoVol
    
    
    /// Instantiate the arrays, and call a running routine
    init()   {
        
        displayLines = [LineSeg]()   // Will get overwritten by test models
        
        displayPoints = [Point3D]()
        
        extent = OrthoVol(minX: -1.25, maxX: 1.25, minY: -1.25, maxY: 1.25, minZ: -1.25, maxZ: 1.25)   // A dummy value
        
        let demoString = "cubic"
        
        switch demoString   {
            
            case "box":  showBox()
        
            case "eff": plotF()
            
            case "segs": makeSegs()
            
            case "stand": standProfile()
            
            case "track": trackSection()
            
            case "cubic": firstCubic()
            
        default:  showBox()   // Demonstrate the boundary box for an Arc
        }
        
    }
    
    /// Build and plot a trial cubic curve
    /// Uses the default value of 'extent'
    func firstCubic()   {
        
        extent = OrthoVol(minX: -62.5, maxX: 62.5, minY: -62.5, maxY: 62.5, minZ: -62.5, maxZ: 62.5)   // Fixed value
        
        let ax = 0.0;
        let bx = 25.0;
        var cx = 60.0;
        var dx = -45.0;
        
        let ay = 0.0;
        let by = -30.0;
        let cy = 30.0;
        var dy = 12.5;
        
        let az = 0.0;
        let bz = 0.0;
        let cz = 0.0;
        let dz = 0.0;
        
        let swoop1 = Cubic(ax: ax, bx: bx, cx: cx, dx: dx, ay: ay, by: by, cy: cy, dy: dy, az: az, bz: bz, cz: cz, dz: dz)

        var priorPt1 = Point3D(x: dx, y: dy, z: dz)   // Starting coordinates for a line segment
        
        cx = 45.0
        dx = -37.5
        
        dy = 5.0
        
        let swoop2 = Cubic(ax: ax, bx: bx, cx: cx, dx: dx, ay: ay, by: by, cy: cy, dy: dy, az: az, bz: bz, cz: cz, dz: dz)
        
        
         // Disregarding the 'draw' function
        
        var priorPt2 = Point3D(x: dx, y: dy, z: dz)
        
        let segs = 15
        let stepSize = 1.0 / Double(segs)
        
        for var g = 1; g <= segs; g++   {
            
            let stepU = Double(g) * stepSize
            
            let stepPoint1 = swoop1.pointAt(stepU)
            let stepPoint2 = swoop2.pointAt(stepU)

            /// LineSeg to be added to the display list
            var stroke: PenCurve
            
            do   {
                
                stroke = try LineSeg(end1: priorPt1, end2: stepPoint1)
                displayLines.append(stroke)
                
                priorPt1 = stepPoint1   // Shuffle values in preparation for the next segment
                
                stroke = try LineSeg(end1: priorPt2, end2: stepPoint2)
                displayLines.append(stroke)
                
                priorPt2 = stepPoint2   // Shuffle values in preparation for the next segment
                
//                var porcu = swoop1.normalAt(stepU)
//                porcu.normalize()
//                print(porcu)
                
            }  catch let error as CoincidentPointsError  {
                let gnirts = error.description
                print(gnirts)
            }  catch  {
                print("Some other error while adding a segment of cubic curve")
            }
            

        }
        
    }
    
    
    /// Build an Arc, then illustrate its surrounding extent
    /// - Returns:  Void, but modifies 'displayLines' and 'displayPoints'
    func showBox()   {
        
        let v = sqrt(3.0) / 2.0
        let ctr = Point3D(x: 0.0, y: 0.0, z: 0.0)
        let start = Point3D(x: 0.5, y: v, z: 0.0)
        let finish = Point3D(x: 1.0, y: 0.0, z: 0.0)
        
        do   {
            
            let bow = try Arc(center: ctr, end1: start, end2: finish, isCW: true)
            bow.setIntent(PenTypes.Arc)
            displayLines.append(bow)
            
            // Optionally draw the extent
            let exDraw = true
            
            if exDraw   {
                
                let boxX = bow.extent.getOrigin().x
                let boxY = bow.extent.getOrigin().y
                
                let lowerLeft = Point3D(x: boxX, y: boxY, z: 0.0)
                let upperLeft = Point3D(x: boxX, y: boxY + bow.extent.getHeight(), z: 0.0)
                
                var rail = try LineSeg(end1: lowerLeft, end2: upperLeft)
                rail.setIntent(PenTypes.Box)
                displayLines.append(rail)
                
                
                let upperRight = Point3D(x: boxX + bow.extent.getWidth(), y: boxY + bow.extent.getHeight(), z: 0.0)
                
                rail = try LineSeg(end1: upperLeft, end2: upperRight)
                rail.setIntent(PenTypes.Box)
                displayLines.append(rail)
                
                
                let lowerRight = Point3D(x: boxX + bow.extent.getWidth(), y: boxY, z: 0.0)
                
                rail = try LineSeg(end1: upperRight, end2: lowerRight)
                rail.setIntent(PenTypes.Box)
                displayLines.append(rail)
                
                rail = try LineSeg(end1: lowerRight, end2: lowerLeft)
                rail.setIntent(PenTypes.Box)
                displayLines.append(rail)
                
            }
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch let error as ArcPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch  {
            print("Some other error while adding a line")
        }
        
    }
    
    
    /// Draw a letter that uses line segments and arcs
    /// Modifies 'displayLines' and 'displayPoints'
    func plotF() -> Void  {
        
        let ptA = Point3D(x: 0.1, y: 0.0, z: 0.0)
        let ptB = Point3D(x: 0.1, y: 0.45, z: 0.0)
        let ptC = Point3D(x: 0.0, y: 0.45, z: 0.0)
        let ptD = Point3D(x: 0.0, y: 0.6, z: 0.0)
        let ptE = Point3D(x: 0.1, y: 0.6, z: 0.0)
        let ptF = Point3D(x: 0.1, y: 0.75, z: 0.0)
        let ptG = Point3D(x: 0.35, y: 0.75, z: 0.0)
        let ptH = Point3D(x: 0.6, y: 0.75, z: 0.0)
        let ptJ = Point3D(x: 0.6, y: 0.7, z: 0.0)
        let ptK = Point3D(x: 0.45, y: 0.7, z: 0.0)
        let ptL = Point3D(x: 0.45, y: 0.75, z: 0.0)
        let ptM = Point3D(x: 0.25, y: 0.75, z: 0.0)
        let ptN = Point3D(x: 0.25, y: 0.6, z: 0.0)
        let ptP = Point3D(x: 0.35, y: 0.6, z: 0.0)
        let ptQ = Point3D(x: 0.35, y: 0.45, z: 0.0)
        let ptR = Point3D(x: 0.25, y: 0.45, z: 0.0)
        let ptS = Point3D(x: 0.25, y: 0.0, z: 0.0)
        
        
        var stroke: PenCurve
        
        do   {
            
            stroke = try LineSeg(end1: ptA, end2: ptB)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptB, end2: ptC)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayLines.append(stroke)
            
            stroke = try Arc(center: ptG, end1: ptF, end2: ptH, isCW: true)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptK, end2: ptL)
            displayLines.append(stroke)
            
            stroke = try Arc(center: ptG, end1: ptL, end2: ptM, isCW: false)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptM, end2: ptN)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptN, end2: ptP)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptP, end2: ptQ)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptQ, end2: ptR)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptR, end2: ptS)
            displayLines.append(stroke)
            
            stroke = try LineSeg(end1: ptS, end2: ptA)
            displayLines.append(stroke)
            
            
            
            
            
            // Build the extent for the figure
            
            extent = displayLines.first!.extent
            for var g = 1; g < displayLines.count; g++  {
                extent = extent + displayLines[g].extent
            }
            
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch  {
            print("Some other error while adding a line")
        }
        
    }
    
    
    /// Show an Arc, then the segments that approximate it
    func makeSegs()   {
        
        let ctr = Point3D(x: -0.25, y: 0.25, z: 0.0)
        let start = Point3D(x: -0.25, y: 0.85, z: 0.0)
        let finish = Point3D(x: -0.85, y: 0.25, z: 0.0)
        
        do   {
            
            let roundEdge = try Arc(center: ctr, end1: start, end2: finish, isCW: false)
            roundEdge.setIntent(PenTypes.Ideal)
            displayLines.append(roundEdge)
            
            
            // Figure how many segments are needed to represent the corner
            
            let maxCrown = 0.05
            
            let arg = (roundEdge.rad - maxCrown) / roundEdge.rad
            let theta = 2.0 * acos(arg)
            
            
            let divisions = ceil(roundEdge.range / theta)
            let divs = Int(divisions)
            
            
            // Show proper number of segments for the Arc to meet the crown requirement
            
            /// The increment in parameter t for each segment
            let tStep = 1.0 / Double(divs)
            
            var thisEnd = roundEdge.pointAt(0.0)
            var thatEnd: Point3D
            
            for var g = 1; g <= divs; g++   {
                
                let currentT = Double(g) * tStep
                
                thatEnd = roundEdge.pointAt(currentT)
                
                let rail = try LineSeg(end1: thisEnd, end2: thatEnd)
                rail.setIntent(PenTypes.Approx)
                displayLines.append(rail)
                
                thisEnd = thatEnd
            }
            
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch let error as ArcPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch  {
            print("Some other error while making a rounded corner")
        }
        
    }
    
    
    
    /// Create the profile for a phone stand
    func standProfile() -> Void   {
        
        do   {
            
            let ptA = Point3D(x: 0.75, y: 1.0, z: 0.0)
            let ptB = Point3D(x: 4.5, y: 10.5, z: 0.0)
            let ptC = Point3D(x: 3.5, y: 14.0, z: 0.0)
            let ptD = Point3D(x: 4.75, y: 14.4, z: 0.0)
            let ptE = Point3D(x: 8.25, y: 2.25, z: 0.0)
            let ptF = Point3D(x: 10.0, y: 3.0, z: 0.0)
            let ptG = Point3D(x: 11.5, y: 5.0, z: 0.0)
            let ptH = Point3D(x: 12.75, y: 5.0, z: 0.0)
            let ptJ = Point3D(x: 10.5, y: 1.0, z: 0.0)
            let ptK = Point3D(x: 7.0, y: 1.0, z: 0.0)
            let ptL = Point3D(x: 5.0, y: 9.0, z: 0.0)
            let ptM = Point3D(x: 2.25, y: 1.0, z: 0.0)
            
            var stroke = try LineSeg(end1: ptA, end2: ptB)
            displayLines.append(stroke)
            
            self.extent = stroke.extent
            
            stroke = try LineSeg(end1: ptB, end2: ptC)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptF, end2: ptG)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptG, end2: ptH)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptK, end2: ptL)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptL, end2: ptM)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptM, end2: ptA)
            displayLines.append(stroke)
            self.extent = self.extent + stroke.extent
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch  {
            print("Some other error while making the stand sketch")
        }
        
    }
    
    /// Show the profile for a wedge-shaped object
    func trackSection()   {
        
        do   {
            
            let ptA = Point3D(x: -5.0, y: 1.0, z: 0.0)
            let ptB = Point3D(x: -8.0, y: 8.0, z: 0.0)
            let ptC = Point3D(x: -4.5, y: 1.866, z: 0.0)
            let ptD = Point3D(x: -2.5, y: 3.0, z: 0.0)
            let ptE = Point3D(x: -2.5, y: 6.0, z: 0.0)
            let ptF = Point3D(x: -7.5, y: 7.134, z: 0.0)
            let ptG = Point3D(x: -7.0, y: 8.0, z: 0.0)
            let ptH = Point3D(x: -1.5, y: 7.0, z: 0.0)
            let ptJ = Point3D(x: -1.5, y: 2.5, z: 0.0)
            let ptK = Point3D(x: -4.0, y: 1.0, z: 0.0)
            
        
            var stroke: PenCurve    // Used to hold arcs and line segments
            
            stroke = try Arc(center: ptA, end1: ptK, end2: ptC, isCW: true)
            displayLines.append(stroke)
            
            self.extent = stroke.extent

            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayLines.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayLines.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayLines.append(stroke)
            
            stroke = try Arc(center: ptB, end1: ptF, end2: ptG, isCW: true)
            displayLines.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptG, end2: ptH)
            displayLines.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayLines.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayLines.append(stroke)
 
            self.extent = self.extent + stroke.extent

            
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch let error as ArcPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch  {
            print("Some other error while making the wedge sketch")
        }
        
    }
    
    
}