//
//  Roundy.swift
//  SketchCurves
//
//  Created by Paul on 11/8/15.
//  Copyright © 2017 Ceran Digital Media. All rights reserved.  See LICENSE.md
//

import UIKit

var modelGeo = DemoPool()

/// A class to run demonstrations of various curve types.  Use 'demoString' to drive the switch statement
class DemoPool  {
    
    /// The display list
    var displayCurves = [PenCurve]()   // Will get filled by test models
    
    
    /// Call a demonstration routine
    init()   {
        
        let demoString = "jout"   // Change this to one of the case names
        
        switch demoString   {
            
        case "box":  showBox()   // Just one case of extent for an Arc
            
        case "chop": chopCubic()   // One intersection of a Line and Cubic
            
        case "chop2": chopCubic2()   // Different intersection of Line and Cubic
            
        case "cubic": demoMatCubic()   // Pair of curves, almost like an offset
            
        case "eff": plotF()   // Suffers from bad extent calculation for Arcs
            
        case "egg": wholeEllipse()   // Which actually is one quarter - with a strange kink near the X-axis
            
        case "herm": demoHermite()   // Single swoopy curve
            
            case "jout": jsOut()   // A bit of text
            
        case "segs": makeSegs()   // Bad arc points, I think.  Try both values for "useSmallAngle"
            
        case "spline": demoSpline()   // Single curve with multiple kinks
            
        case "stand": standProfile()  // Crude profile from just LineSeg's
            
        case "track": trackSection()   // Works, with bad scaling
            
            
        default:  showBox()   // Demonstrate the boundary box for an Arc
            
        }
        
    }
    
    /// Experiment with creating JS
    func jsOut() -> Void   {
        
        let ptG = Point3D(x: 1.80, y: 1.40, z: 0.0)
        let ptW = Point3D(x: 2.10, y: 1.95, z: 0.0)
        
        /// Line segment to test output generation
        let arrow1 = try! LineSeg(end1: ptG, end2: ptW)   // Should be fine with those explicit values
        displayCurves.append(arrow1)
        
        let tform = Transform(scaleX: 10.0, scaleY: 10.0, scaleZ: 10.0)
        var jsline = arrow1.jsDraw(xirtam: tform)
        
        print(jsline)
        
        
        let ptA = Point3D(x: 1.80, y: 1.40, z: 0.0)
        let ptB = Point3D(x: 2.10, y: 1.95, z: 0.0)
        let ptC = Point3D(x: 2.70, y: 2.30, z: 0.0)
        let ptD = Point3D(x: 3.50, y: 2.05, z: 0.0)
        
        let target = Cubic(alpha: ptA, beta: ptB, betaFraction: 0.35, gamma: ptC, gammaFraction: 0.70, delta: ptD)
        displayCurves.append(target)
                
        jsline = target.jsDraw(xirtam: tform)
        
        print(jsline)
        
    }

    /// Experiment with line - cubic intersections
    func chopCubic() -> Void   {
        
        let ptA = Point3D(x: 1.80, y: 1.40, z: 0.0)
        let ptB = Point3D(x: 2.10, y: 1.95, z: 0.0)
        let ptC = Point3D(x: 2.70, y: 2.30, z: 0.0)
        let ptD = Point3D(x: 3.50, y: 2.05, z: 0.0)
        
        let target = Cubic(alpha: ptA, beta: ptB, betaFraction: 0.35, gamma: ptC, gammaFraction: 0.70, delta: ptD)
        displayCurves.append(target)
        
        let ptE = Point3D(x: 2.50, y: 1.30, z: 0.0)
        let ptF = Point3D(x: 3.35, y: 2.20, z: 0.0)
        
        /// Line segment to test for intersection
        let arrow1 = try! LineSeg(end1: ptE, end2: ptF)   // Should be fine with those explicit values
        displayCurves.append(arrow1)
        
        /// Line made from the LineSeg
        let ray = try! Line(spot: arrow1.getOneEnd(), arrow: arrow1.getDirection())   // No worries with this vector
        
        let spots = target.intersect(ray: ray, accuracy: 0.001)
        
        print("Location of intersections: " +  String(describing: spots.first!))
    }
    
    
    /// Different Line / Cubic intersection case
    func chopCubic2() -> Void {
        
        let ax = 0.016
        let bx = -0.108
        let cx = -0.174
        let dx = 0.571
        let ay = -0.023
        let by = 0.180
        let cy = -0.291
        let dy = 0.119
        let az = 0.0
        let bz = 0.0
        let cz = 0.0
        let dz = 0.0
        
        let bowl = Cubic(ax: ax, bx: bx, cx: cx, dx: dx, ay: ay, by: by, cy: cy, dy: dy, az: az, bz: bz, cz: cz, dz: dz)
        displayCurves.append(bowl)
        
        
        let ptC = Point3D(x: 0.02, y: 0.065, z: 0.0)
        let ptD = Point3D(x: 0.59, y: 0.065, z: 0.0)
        
        let horizon2 = try! LineSeg(end1: ptC, end2: ptD)   // Should be fine with those explicit values
        
        let ray2 = try! Line(spot: ptC, arrow: horizon2.getDirection())   // No worries with this vector
        
        displayCurves.append(horizon2)
        
        let pots = bowl.intersect(ray: ray2, accuracy: 0.001)
        print(pots.count)
        
    }
    
    
    /// Build and plot one quarter of an ellipse
    /// Kink near the X-axis?
    /// Needs to be modified to use its own 'draw' function
    func wholeEllipse()   {
        
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
            print(error.description)
        } catch  {
            print("Some other error while adding a segment of an ellipse")
        }
        
    }
    
    /// Build and plot a cubic curve entirely from the matrix coefficients
    func demoMatCubic()   {
        
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
            
            let stepPoint1 = try! swoop1.pointAt(t: stepU)
            let stepPoint2 = try! swoop2.pointAt(t: stepU)

            /// LineSeg to be added to the display list
            var stroke: PenCurve
            
            do   {
                
                stroke = try LineSeg(end1: priorPt1, end2: stepPoint1)
                displayCurves.append(stroke)
                
                priorPt1 = stepPoint1   // Shuffle values in preparation for the next segment
                
                stroke = try LineSeg(end1: priorPt2, end2: stepPoint2)
                displayCurves.append(stroke)
                
                priorPt2 = stepPoint2   // Shuffle values in preparation for the next segment
                
                
            }  catch let error as CoincidentPointsError  {
                print(error.description)
            }  catch  {
                print("Some other error while adding a segment of cubic curve")
            }
            
        }
        
    }
    
    
    /// Build and plot a trial cubic curve
    func demoHermite()   {
        
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
            
            let stepPoint1 = try! bump.pointAt(t: stepU)
            
            /// LineSeg to be added to the display list
            var stroke: PenCurve
            
            do   {
                
                stroke = try LineSeg(end1: priorPt1, end2: stepPoint1)
                displayCurves.append(stroke)
                
                priorPt1 = stepPoint1   // Shuffle values in preparation for the next segment
                
            }  catch let error as CoincidentPointsError  {
                print(error.description)
            }  catch  {
                print("Some other error while adding a segment of a Hermite cubic curve")
            }
    
        }
    }
    
    /// Build and plot a trial cubic curve
    func demoSpline()   {
        
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
            
            var priorPt1 = try! piece.pointAt(t: 0.0)
            
            let segs = 10
            let stepSize = 1.0 / Double(segs)
            
            for g in 1...segs  {
                let stepU = Double(g) * stepSize
                
                let stepPoint1 = try! piece.pointAt(t: stepU)
                
                /// LineSeg to be added to the display list
                var stroke: PenCurve
                
                do   {
                    
                    stroke = try LineSeg(end1: priorPt1, end2: stepPoint1)
                    displayCurves.append(stroke)
                    
                    priorPt1 = stepPoint1   // Shuffle values in preparation for the next segment
                    
                }  catch let error as CoincidentPointsError  {
                    print(error.description)
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
                
                let boxX = bow.getExtent().getOrigin().x
                let boxY = bow.getExtent().getOrigin().y
                
                let lowerLeft = Point3D(x: boxX, y: boxY, z: 0.0)
                let upperLeft = Point3D(x: boxX, y: boxY + bow.getExtent().getHeight(), z: 0.0)
                
                var rail = try LineSeg(end1: lowerLeft, end2: upperLeft)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
                
                let upperRight = Point3D(x: boxX + bow.getExtent().getWidth(), y: boxY + bow.getExtent().getHeight(), z: 0.0)
                
                rail = try LineSeg(end1: upperLeft, end2: upperRight)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
                
                let lowerRight = Point3D(x: boxX + bow.getExtent().getWidth(), y: boxY, z: 0.0)
                
                rail = try LineSeg(end1: upperRight, end2: lowerRight)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
                rail = try LineSeg(end1: lowerRight, end2: lowerLeft)
                rail.setIntent(PenTypes.extent)
                displayCurves.append(rail)
                
            }
            
        }  catch let error as CoincidentPointsError   {
            print(error.description)
        }  catch let error as ArcPointsError  {
            print(error.description)
        }  catch  {
            print("Some other error while showing an Arc extent")
        }
        
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
            
            let outOfPage = Vector3D(i: 0.0, j: 0.0, k: 1.0)
            stroke = try Arc(center: ptG, axis: outOfPage, end1: ptF, sweep: -Double.pi)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptK, end2: ptL)
            displayCurves.append(stroke)

            stroke = try Arc(center: ptG, axis: outOfPage, end1: ptL, sweep: Double.pi)
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
            
            
        }  catch let error as CoincidentPointsError  {
            let gnirts = error.description
            print(gnirts)
        }  catch let error as ZeroVectorError  {
            let gnirts = error.description
            print(gnirts)
        }  catch let error as NonUnitDirectionError  {
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
            
            let roundEdge = try Arc(center: ctr, end1: start, end2: finish, useSmallAngle: false)
            roundEdge.setIntent(purpose: PenTypes.ideal)
            displayCurves.append(roundEdge)
            
            
               // Figure how many segments are needed to represent the corner
            
            let maxCrown = 0.05
            
            let arg = (roundEdge.getRadius() - maxCrown) / roundEdge.getRadius()
            let crownTheta = 2.0 * acos(arg)
            
            
            let divisions = abs(ceil(roundEdge.getSweepAngle() / crownTheta))
            let divs = Int(divisions)
            
            
               // Show proper number of segments for the Arc to meet the crown requirement
            
            /// The increment in parameter t for each segment
            let tStep = 1.0 / Double(divs)
            
            var thisEnd = try! roundEdge.pointAt(t: 0.0)
            var thatEnd: Point3D
            
            for g in 1...divs   {
                
                let currentT = Double(g) * tStep
                
                thatEnd = try! roundEdge.pointAt(t: currentT)
                
                let rail = try LineSeg(end1: thisEnd, end2: thatEnd)
                rail.setIntent(PenTypes.approx)
                displayCurves.append(rail)
                
                thisEnd = thatEnd
            }
            
        }  catch let error as CoincidentPointsError  {
            print(error.description)
        }  catch let error as ArcPointsError  {
            print(error.description)
        }  catch  {
            print("Some other error while making a rounded corner")
        }
        
    }
    
    
    
    /// Create the profile for a phone stand with line segments
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
            
            
            stroke = try LineSeg(end1: ptB, end2: ptC)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptF, end2: ptG)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptG, end2: ptH)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptK, end2: ptL)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptL, end2: ptM)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptM, end2: ptA)
            displayCurves.append(stroke)
            
            
        }  catch let error as CoincidentPointsError  {
            print(error.description)
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
            
            stroke = try LineSeg(end1: ptC, end2: ptD)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptD, end2: ptE)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptE, end2: ptF)
            displayCurves.append(stroke)
            
            stroke = try Arc(center: ptB, end1: ptF, end2: ptG, useSmallAngle: false)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptG, end2: ptH)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptH, end2: ptJ)
            displayCurves.append(stroke)
            
            stroke = try LineSeg(end1: ptJ, end2: ptK)
            displayCurves.append(stroke)
 
            
        }  catch let error as CoincidentPointsError  {
            print(error.description)
        }  catch let error as ArcPointsError  {
            print(error.description)
        }  catch  {
            print("Some other error while making the track sketch")
        }
        
    }
    
}
