//
//  Easel.swift
//

import UIKit

/// A utility canvas for showing objects in two dimensions
/// - Attention: This class name needs to linked in the storyboard's Identity Inspector in an app to be seen
/// - Requires: A global parameter named modelGeo that contains lines to be drawn, and points that terminate the line segments
/// - Note: Uses statements from Swift 2.0 and later
class Easel2D: UIView {
    
    override func drawRect(rect: CGRect) {
        
        guard !modelGeo.displayLines.isEmpty else {    // Bail if there isn't anything to plot
            print("Nothing to plot!")
            return
        }
        
        /// Flag showing whether or not the scale has been set
        var isScaled = false
        
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context);    // Preserve settings that were used before
        
        /// A parameter to keep line widths from going bonkers - default value
        var undoScale = CGFloat(1.0)
        
        if !isScaled    {
        
            let plotParameters = findScaleAndCenter(rect)    // "rect" is passed in to drawRect
            
            CGContextTranslateCTM(context, plotParameters.translateX, plotParameters.translateY);
            CGContextScaleCTM(context, plotParameters.scale, -plotParameters.scale);   // To get positive Y upwards on the screen
            
            undoScale = CGFloat(1.0) / plotParameters.scale
            
            isScaled = true
        }
        
        
            // Prepare colors
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let blackComponents: [CGFloat] = [0.0, 0.0, 0.0, 1.0]
        let black = CGColorCreate(colorSpace, blackComponents)
        let blueComponents: [CGFloat] = [0.0, 0.0, 1.0, 1.0]
        let blue = CGColorCreate(colorSpace, blueComponents)
        let greenComponents: [CGFloat] = [0.0, 1.0, 0.0, 1.0]
        let green = CGColorCreate(colorSpace, greenComponents)
        let greyComponents: [CGFloat] = [0.7, 0.7, 0.7, 1.0]
        let grey = CGColorCreate(colorSpace, greyComponents)
//        let redComponents: [CGFloat] = [1.0, 0.0, 0.0, 1.0]
//        let red = CGColorCreate(colorSpace, redComponents)
//        let cyanComponents: [CGFloat] = [0.0, 1.0, 1.0, 1.0]
//        let cyan = CGColorCreate(colorSpace, cyanComponents)
        let brownComponents: [CGFloat] = [0.6, 0.35, 0.16, 1.0]
        let brown = CGColorCreate(colorSpace, brownComponents)
        
            // Prepare pen widths
        let thick = CGFloat(3.0) * undoScale
        let standard = CGFloat(2.0) * undoScale
        let thin = CGFloat(1.0) * undoScale
        
        
        
        
        for wire in modelGeo.displayLines   {    // Traverse through the entire collection of displayLines
            
                // Choose the appropriate pen
            switch wire.usage  {
                
            case .Arc:
                CGContextSetStrokeColorWithColor(context, blue)
                CGContextSetLineWidth(context, thick)
                CGContextSetLineDash(context, 0.0, nil, 0);    // To clear any previous dash pattern
                
            case .Sweep:
                CGContextSetStrokeColorWithColor(context, grey)
                CGContextSetLineWidth(context, thin)
                let dashArray =  [CGFloat(3) * undoScale, CGFloat(3) * undoScale]
                CGContextSetLineDash(context, 0.0, dashArray, 2);
                                
            case .Box:
                CGContextSetStrokeColorWithColor(context, brown)
                CGContextSetLineWidth(context, thin)
                let dashArray =  [CGFloat(10) * undoScale, CGFloat(4) * undoScale]
                CGContextSetLineDash(context, 0.0, dashArray, 2);
                
            case .Ideal:
                CGContextSetStrokeColorWithColor(context, black)
                CGContextSetLineWidth(context, thin)
                let dashArray =  [CGFloat(3) * undoScale, CGFloat(3) * undoScale]
                CGContextSetLineDash(context, 0.0, dashArray, 2);    // To clear any previous dash pattern
                
            case .Approx:
                CGContextSetStrokeColorWithColor(context, green)
                CGContextSetLineWidth(context, standard)
                CGContextSetLineDash(context, 0.0, nil, 0);    // To clear any previous dash pattern
                
            case .Default:
                CGContextSetStrokeColorWithColor(context, black)
                CGContextSetLineWidth(context, thin)
                CGContextSetLineDash(context, 0.0, nil, 0);    // To clear any previous dash pattern
                
            }
            
            
            wire.draw(context!)
            
        }   // End of loop through the display list
        
        
        CGContextRestoreGState(context);    // Restore prior settings
        
    }    // End of drawRect
    
    
    
    
    /// Determines parameters to center the model on the screen.
    /// - Parameter: displayRect: Bounds of the plotting area
    /// - Returns: A tuple containing the scale, and translation parameters
    func  findScaleAndCenterOld(displayRect: CGRect) -> (scale: CGFloat, translateX: CGFloat, translateY: CGFloat)   {
        
        // Find the range in X values, and also in Y
        let somePt: Point3D = modelGeo.displayPoints.first!
        
        var minX: Double = somePt.x
        var maxX: Double = somePt.x
        var minY: Double = somePt.y
        var maxY: Double = somePt.y
        
        // Iterate through the array updating the min and max for both axes
        for pt in modelGeo.displayPoints    {
            
            if pt.x < minX {
                minX = pt.x
            } else if pt.x > maxX {
                maxX = pt.x
            }
            
            
            if pt.y < minY {
                minY = pt.y
            } else if pt.y > maxY {
                maxY = pt.y
            }
            
        }
        
//        print("X from " + String(minX) + " to " + String(maxX) + "  Y from " + String(minY) + " to " + String(maxY))
        
        let rangeX = maxX - minX
        let rangeY = maxY - minY
        
        let margin = 20.0   // Force this to be used as a double
        
        // This is making an assumption about device orientation, I think
        let scaleX = (Double(displayRect.width) - 2.0 * margin) / rangeX
        let scaleY = (Double(displayRect.height) - 2.0 * margin) / rangeY
        
        let scale = min(scaleX, scaleY)
        
        
        
        
        // Find the middle of the model area for translation
        let middleX = (minX + maxX) / 2.0
        let middleY = (minY + maxY) / 2.0
        
        let transX = Double(displayRect.width) / 2 - middleX * scale
        let transY = Double(displayRect.height) / 2 + middleY * scale
        
        return (CGFloat(scale), CGFloat(transX), CGFloat(transY))
        
    }
    
    /// Determines parameters to center the model on the screen.
    /// - Parameter: displayRect: Bounds of the plotting area
    /// - Requires: A CGRect as part of modelGeo that bounds the model space used
    /// - Returns: A tuple containing the scale, and translation parameters
    func  findScaleAndCenter(displayRect: CGRect) -> (scale: CGFloat, translateX: CGFloat, translateY: CGFloat)   {
        
        let rangeX = modelGeo.extent.getWidth()
        let rangeY = modelGeo.extent.getHeight()
        
        let margin = 10.0   // Force this to be used as a double
        
        let scaleX = (Double(displayRect.width) - 2.0 * margin) / rangeX
        let scaleY = (Double(displayRect.height) - 2.0 * margin) / rangeY
        
        let scale = min(scaleX, scaleY)
        
        
             // Find the middle of the model area for translation
        let giro = modelGeo.extent.getOrigin()
        
        let middleX = giro.x + 0.5 * rangeX
        let middleY = giro.y + 0.5 * rangeY
        
        let transX = (Double(displayRect.width) - 2.0 * margin) / 2 - Double(middleX) * scale + margin
        let transY = (Double(displayRect.height) - 2.0 * margin) / 2 + Double(middleY) * scale + margin
        
        return (CGFloat(scale), CGFloat(transX), CGFloat(transY))
        
    }
}
