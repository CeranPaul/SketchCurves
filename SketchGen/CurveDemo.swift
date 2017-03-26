//
//  Roundy.swift
//  SketchCurves
//
//  Created by Paul on 11/8/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

var modelGeo = Roundy()

/// A class to run demonstrations of various curve types.  Use 'demoString' to drive the switch statement
class Roundy  {
    
    /// The display list
    var displayCurves: [PenCurve]
    
    
    /// Bounding area for play
    var arena = CGRect(x: -5.0, y: -5.0, width: 20.0, height: 20.0)
    
    /// Rectangle encompassing all of the curves to be displayed
    var extent: OrthoVol
    
    
    /// Instantiate the arrays, and call a running routine
    init()   {
        
        displayCurves = [PenCurve]()   // Will get overwritten by test models
        
        
        extent = OrthoVol(minX: -1.25, maxX: 1.25, minY: -1.25, maxY: 1.25, minZ: -1.25, maxZ: 1.25)   // A dummy value
        
        let demoString = "herm"
        
        switch demoString   {
            
        case "box":  showBox()   // Just one case
            
        case "eff": plotF()   // Broken
            
        case "segs": makeSegs()   // Try both values for "useSmallAngle"
            
        case "stand": standProfile()
            
        case "track": trackSection()   // Works with bad scaling
            
        case "cubic": firstCubic()   // Pair of curves, almost like an offset
            
        case "egg": wholeEllipse()   // Which actually is one quarter
            
        case "herm": firstHermite()
            
        case "spline": firstSpline()
            
            
        default:  showBox()   // Demonstrate the boundary box for an Arc
            
        }
        
    }
    
    /// Print unobscured by test results and multiple calls to target function
    func ArcDebug() -> Void   {
        
    }
    
    /// Build and plot an entire ellipse
    func wholeEllipse()   {
        
        extent = OrthoVol(minX: -62.5, maxX: 62.5, minY: -62.5, maxY: 62.5, minZ: -62.5, maxZ: 62.5)   // Fixed value
        arena = CGRect(x: -62.5, y: -62.5, width: 125.0, height: 125.0)
        
        let a = 50.0
        let b = 30.0
        let ctr = Point3D(x: 0.0, y: 0.0, z: 0.0)
        let sf = Point3D(x: 50.0, y: 0.0, z: 0.0)
        
        let oval = Ellipse(retnec: ctr, a: a, b: b, azimuth: 0.0, start: sf, finish: sf)
        
        
        /// Generate line segments to represent the curve
        
            let divs = 50
            let step = a / Double(divs)
            
            let home = oval.getCenter()
        
            var greenFlag = Point3D(x: home.x, y: home.y + b, z: home.z)
        
        var g = 1
        
        do   {
            
            repeat   {
                
                let newX = Double(g) * step
                let newY = oval.findY(newX)
                let checkeredFlag = Point3D(x: home.x + newX, y: home.y + newY, z: home.z)
                
                let stroke = try LineSeg(end1: greenFlag, end2: checkeredFlag)
                displayCurves.append(stroke)
        
                greenFlag = checkeredFlag
                g += 1
        
            } while g <= divs
        
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        } catch  {
            print("Some other error while adding a segment of an ellipse")
        }
        
    }
    
    /// Build and plot a trial cubic curve
    /// Uses the default value of 'extent'
    func firstCubic()   {
        
        extent = OrthoVol(minX: -62.5, maxX: 62.5, minY: -62.5, maxY: 62.5, minZ: -62.5, maxZ: 62.5)   // Fixed value
        arena = CGRect(x: -62.5, y: -62.5, width: 125.0, height: 125.0)
        
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
        
        for g in 1..<segs  {
            let stepU = Double(g) * stepSize
            
            let stepPoint1 = swoop1.pointAt(t: stepU)
            let stepPoint2 = swoop2.pointAt(t: stepU)

            /// LineSeg to be added to the display list
            var stroke: PenCurve
            
            do   {
                
                stroke = try LineSeg(end1: priorPt1, end2: stepPoint1)
                displayCurves.append(stroke)
                
                priorPt1 = stepPoint1   // Shuffle values in preparation for the next segment
                
                stroke = try LineSeg(end1: priorPt2, end2: stepPoint2)
                displayCurves.append(stroke)
                
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
    
    
    /// Build and plot a trial cubic curve
    func firstHermite()   {
        
        extent = OrthoVol(minX: 1.75, maxX: 3.5, minY: 1.0, maxY: 3.0, minZ: -1.0, maxZ: 1.0)   // Fixed value
        arena = CGRect(x: 1.75, y: 1.0, width: 1.75, height: 2.0)
        
        let alpha = Point3D(x: 2.3, y: 1.5, z: 0.7)
        let alSlope = Vector3D(i: 0.866, j: -0.5, k: 0.0)
        
        let beta = Point3D(x: 3.1, y: 1.6, z: 0.7)
        let betSlope = Vector3D(i: 0.866, j: 0.5, k: 0.0)
        
        let bump = Cubic(ptA: alpha, slopeA: alSlope, ptB: beta, slopeB: betSlope)
        
        
        // Disregarding the 'draw' function
        
        var priorPt1 = alpha
        
        let segs = 15
        let stepSize = 1.0 / Double(segs)
        
        for g in 1..<segs  {
            let stepU = Double(g) * stepSize
            
            let stepPoint1 = bump.pointAt(t: stepU)
            
            /// LineSeg to be added to the display list
            var stroke: PenCurve
            
            do   {
                
                stroke = try LineSeg(end1: priorPt1, end2: stepPoint1)
                displayCurves.append(stroke)
                
                priorPt1 = stepPoint1   // Shuffle values in preparation for the next segment
                
            }  catch let error as CoincidentPointsError  {
                let gnirts = error.description
                print(gnirts)
            }  catch  {
                print("Some other error while adding a segment of a Hermite cubic curve")
            }
    
        }
    }
    
    /// Build and plot a trial cubic curve
    func firstSpline()   {
        
        extent = OrthoVol(minX: -1.00, maxX: 1.5, minY: -1.5, maxY: 1.5, minZ: 3.0, maxZ: 5.0)   // Fixed value
        arena = CGRect(x: -1.00, y: -1.5, width: 2.5, height: 3.0)
        
        var lilyPads = [Point3D]()
        
        let a = Point3D(x: 0.25, y: -1.5, z: 4.2)
        lilyPads.append(a)
        
        let b = Point3D(x: 0.60, y: -0.75, z: 4.2)
        lilyPads.append(b)
        
        let c = Point3D(x: 0.80, y: -0.15, z: 4.2)
        lilyPads.append(c)
        
        let d = Point3D(x: 0.40, y: 0.25, z: 4.2)
        lilyPads.append(d)
        
        let e = Point3D(x: -0.10, y: 0.65, z: 4.2)
        lilyPads.append(e)
        
        let swing = Spline(pts: lilyPads)
        
        for piece in swing.pieces   {
            
            var priorPt1 = piece.pointAt(t: 0.0)
            
            let segs = 10
            let stepSize = 1.0 / Double(segs)
            
            for g in 1...segs  {
                let stepU = Double(g) * stepSize
                
                let stepPoint1 = piece.pointAt(t: stepU)
                
                /// LineSeg to be added to the display list
                var stroke: PenCurve
                
                do   {
                    
                    stroke = try LineSeg(end1: priorPt1, end2: stepPoint1)
                    displayCurves.append(stroke)
                    
                    priorPt1 = stepPoint1   // Shuffle values in preparation for the next segment
                    
                }  catch let error as CoincidentPointsError  {
                    let gnirts = error.description
                    print(gnirts)
                }  catch  {
                    print("Some other error while adding a segment of a Hermite cubic curve")
                }
                
            }
        }   // End of outer loop
    }
    
    /// Build an Arc, then illustrate its surrounding extent
    /// - Returns:  Void, but modifies 'displayCurves'
    func showBox()   {
                
        let v = sqrt(3.0) / 2.0
        let ctr = Point3D(x: 0.0, y: 0.0, z: 0.0)
        let start = Point3D(x: 0.5, y: v, z: 0.0)
        let finish = Point3D(x: 1.0, y: 0.0, z: 0.0)
        
        do   {
            
            // The Boolean seems to be reversed
            let bow = try Arc(center: ctr, end1: start, end2: finish, useSmallAngle: false)
            bow.setIntent(purpose: PenTypes.arc)
            displayCurves.append(bow)
            
            // Optionally draw the extent
            let exDraw = true
            
            if exDraw   {
                
                let boxX = bow.extent.getOrigin().x
                let boxY = bow.extent.getOrigin().y
                
                let lowerLeft = Point3D(x: boxX, y: boxY, z: 0.0)
                let upperLeft = Point3D(x: boxX, y: boxY + bow.extent.getHeight(), z: 0.0)
                
                var rail = try LineSeg(end1: lowerLeft, end2: upperLeft)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
                
                let upperRight = Point3D(x: boxX + bow.extent.getWidth(), y: boxY + bow.extent.getHeight(), z: 0.0)
                
                rail = try LineSeg(end1: upperLeft, end2: upperRight)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
                
                let lowerRight = Point3D(x: boxX + bow.extent.getWidth(), y: boxY, z: 0.0)
                
                rail = try LineSeg(end1: upperRight, end2: lowerRight)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
                rail = try LineSeg(end1: lowerRight, end2: lowerLeft)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
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
        
        arena = CGRect(x: extent.getOrigin().x, y: extent.getOrigin().y, width: extent.getWidth(), height: extent.getHeight())
        
    }
    
    
    /// Draw a letter that uses line segments and arcs
    /// Modifies 'displayCurves'
    func plotF() -> Void  {
        
        let ptA = Point3D(x: 0.1, y: 0.0, z: 0.0)
        let ptB = Point3D(x: 0.1, y: 0.45, z: 0.0)
        let ptC = Point3D(x: 0.0, y: 0.45, z: 0.0)
        let ptD = Point3D(x: 0.0, y: 0.6, z: 0.0)
        let ptE = Point3D(x: 0.1, y: 0.6, z: 0.0)
        let ptF = Point3D(x: 0.1, y: 0.75, z: 0.0)
        let ptG = Point3D(x: 0.35, y: 0.75, z: 0.0)
        let ptH = Point3D(x: 0.6, y: 0.77, z: 0.0)
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
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptB, end2: ptC)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayCurves.append(stroke)
            
               // This will blow up!
            stroke = try Arc(center: ptG, end1: ptF, end2: ptH, useSmallAngle: false)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptK, end2: ptL)
            displayCurves.append(stroke)
            
               // This will blow up!
            stroke = try Arc(center: ptG, end1: ptL, end2: ptM, useSmallAngle: false)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptM, end2: ptN)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptN, end2: ptP)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptP, end2: ptQ)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptQ, end2: ptR)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptR, end2: ptS)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptS, end2: ptA)
            displayCurves.append(stroke)
            
            
            
            // Build the extent for the figure   Is there a way to do this as a 'reduce' closure?
            
            extent = displayCurves.first!.extent
            for g in 1..<displayCurves.count  {
                extent = extent + displayCurves[g].extent
            }
            
            arena = CGRect(x: extent.getOrigin().x, y: extent.getOrigin().y, width: extent.getWidth(), height: extent.getHeight())
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch  {
            print("Some other error while adding a line")
        }
        
//        arena = CGRect(x: -0.25, y: -0.25, width: 1.5, height: 1.5)
        
    }
    
    
    /// Show an Arc, then the segments that approximate it
    func makeSegs()   {
        
        let ctr = Point3D(x: -0.25, y: 0.25, z: 0.0)
        let start = Point3D(x: -0.25, y: 0.85, z: 0.0)
        let finish = Point3D(x: -0.85, y: 0.25, z: 0.0)
        
        do   {
            
            let roundEdge = try Arc(center: ctr, end1: start, end2: finish, useSmallAngle: false)
            roundEdge.setIntent(purpose: PenTypes.ideal)
            displayCurves.append(roundEdge)
            
            
            // Figure how many segments are needed to represent the corner
            
            let maxCrown = 0.05
            
            let arg = (roundEdge.getRadius() - maxCrown) / roundEdge.getRadius()
            let crownTheta = 2.0 * acos(arg)
            
            
            let divisions = ceil(roundEdge.getSweepAngle() / crownTheta)
            let divs = abs(Int(divisions))
            
            
            // Show proper number of segments for the Arc to meet the crown requirement
            
            /// The increment in parameter t for each segment
            let tStep = 1.0 / Double(divs)
            
            var thisEnd = roundEdge.pointAt(t: 0.0)
            var thatEnd: Point3D
            
            for g in 1...divs   {
                
                let currentT = Double(g) * tStep
                
                thatEnd = roundEdge.pointAt(t: currentT)
                
                let rail = try LineSeg(end1: thisEnd, end2: thatEnd)
                rail.setIntent(PenTypes.approx)
                displayCurves.append(rail)
                
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
        
        arena = CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0)
        
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
            displayCurves.append(stroke)
            
            self.extent = stroke.extent
            
            stroke = try LineSeg(end1: ptB, end2: ptC)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptF, end2: ptG)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptG, end2: ptH)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptK, end2: ptL)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptL, end2: ptM)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptM, end2: ptA)
            displayCurves.append(stroke)
            self.extent = self.extent + stroke.extent
            
            arena = CGRect(x: extent.getOrigin().x, y: extent.getOrigin().y, width: extent.getWidth(), height: extent.getHeight())
            
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
            
            stroke = try Arc(center: ptA, end1: ptK, end2: ptC, useSmallAngle: false)
            displayCurves.append(stroke)
            
            self.extent = stroke.extent

            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayCurves.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayCurves.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayCurves.append(stroke)
            
            stroke = try Arc(center: ptB, end1: ptF, end2: ptG, useSmallAngle: false)
            displayCurves.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptG, end2: ptH)
            displayCurves.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayCurves.append(stroke)
            
            self.extent = self.extent + stroke.extent
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayCurves.append(stroke)
 
            self.extent = self.extent + stroke.extent

            arena = CGRect(x: extent.getOrigin().x, y: extent.getOrigin().y, width: extent.getWidth(), height: extent.getHeight())
            
            
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch let error as ArcPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch  {
            print("Some other error while making the track sketch")
        }
        
//        arena = CGRect(x: -10.0, y: -10.0, width: 20.0, height: 20.0)
        
    }
    
    
}
