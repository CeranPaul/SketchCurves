//
//  Easel.swift
//

import UIKit

/// A utility canvas for showing objects in two dimensions
/// - Attention: This class name needs to linked in the storyboard's Identity Inspector in an app to be seen
/// - Requires: A global parameter named modelGeo that contains lines to be drawn, and points that terminate the line segments
/// - Note: Uses statements from Swift 2.0 and later
class Easel2D: UIView {
    
    override func draw(_ rect: CGRect) {
        
        guard !modelGeo.displayLines.isEmpty else {    // Bail if there isn't anything to plot
            print("Nothing to plot!")
            return
        }
        
        /// Flag showing whether or not the scale has been set
        var isScaled = false
        
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState();    // Preserve settings that were used before
        
        /// A parameter to keep line widths from going bonkers - default value
        var undoScale = CGFloat(1.0)
        
        if !isScaled    {
        
            let plotParameters = findScaleAndCenter(rect)    // "rect" is passed in to drawRect
            
            context?.translateBy(x: plotParameters.translateX, y: plotParameters.translateY);
            context?.scaleBy(x: plotParameters.scale, y: -plotParameters.scale);   // To get positive Y upwards on the screen
            
            undoScale = CGFloat(1.0) / plotParameters.scale
            
            isScaled = true
        }
        
        
            // Prepare colors
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let blackComponents: [CGFloat] = [0.0, 0.0, 0.0, 1.0]
        let black = CGColor(colorSpace: colorSpace, components: blackComponents)
        let blueComponents: [CGFloat] = [0.0, 0.0, 1.0, 1.0]
        let blue = CGColor(colorSpace: colorSpace, components: blueComponents)
        let greenComponents: [CGFloat] = [0.0, 1.0, 0.0, 1.0]
        let green = CGColor(colorSpace: colorSpace, components: greenComponents)
        let greyComponents: [CGFloat] = [0.7, 0.7, 0.7, 1.0]
        let grey = CGColor(colorSpace: colorSpace, components: greyComponents)
//        let redComponents: [CGFloat] = [1.0, 0.0, 0.0, 1.0]
//        let red = CGColorCreate(colorSpace, redComponents)
//        let cyanComponents: [CGFloat] = [0.0, 1.0, 1.0, 1.0]
//        let cyan = CGColorCreate(colorSpace, cyanComponents)
        let brownComponents: [CGFloat] = [0.6, 0.35, 0.16, 1.0]
        let brown = CGColor(colorSpace: colorSpace, components: brownComponents)
        
            // Prepare pen widths
        let thick = CGFloat(3.0) * undoScale
        let standard = CGFloat(2.0) * undoScale
        let thin = CGFloat(1.0) * undoScale
        
        
        
        
        for wire in modelGeo.displayLines   {    // Traverse through the entire collection of displayLines
            
                // Choose the appropriate pen
            switch wire.usage  {
                
            case .arc:
                context?.setStrokeColor(blue!)
                context?.setLineWidth(thick)
                context?.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
                
            case .sweep:
                context?.setStrokeColor(grey!)
                context?.setLineWidth(thin)
                context?.setLineDash(phase: 0, lengths: [CGFloat(10) * undoScale, CGFloat(8) * undoScale]);
                                
            case .box:
                context?.setStrokeColor(brown!)
                context?.setLineWidth(thin)
                context?.setLineDash(phase: 5 * undoScale, lengths: [CGFloat(10) * undoScale, CGFloat(8) * undoScale])    // To clear any previous dash pattern
                
            case .ideal:
                context?.setStrokeColor(black!)
                context?.setLineWidth(thin)
                context?.setLineDash(phase: 0, lengths: [CGFloat(3) * undoScale, CGFloat(3) * undoScale])    // To clear any previous dash pattern
                
            case .approx:
                context?.setStrokeColor(green!)
                context?.setLineWidth(standard)
                context?.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
                
            case .default:
                context?.setStrokeColor(black!)
                context?.setLineWidth(thin)
                context?.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
                
            }
            
            
            wire.draw(context!)
            
        }   // End of loop through the display list
        
        
        context?.restoreGState();    // Restore prior settings
        
    }    // End of drawRect
    
    
    
    
    /// Determines parameters to center the model on the screen.
    /// - Parameter: displayRect: Bounds of the plotting area
    /// - Returns: A tuple containing the scale, and translation parameters
    func  findScaleAndCenterOld(_ displayRect: CGRect) -> (scale: CGFloat, translateX: CGFloat, translateY: CGFloat)   {
        
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
    func  findScaleAndCenter(_ displayRect: CGRect) -> (scale: CGFloat, translateX: CGFloat, translateY: CGFloat)   {
        
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
