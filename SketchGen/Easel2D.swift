//
//  Easel2D.swift
//  SketchCurves
//

import UIKit

/// A utility canvas for showing objects in two dimensions
/// - Attention: This class name needs to linked in the storyboard's Identity Inspector in an app to be seen
/// - Requires: A global parameter named modelGeo that contains curves to be drawn
class Easel2D: UIView {
    
       // Declare pen properties
    var black: CGColor
    var blue: CGColor
    var green: CGColor
    var grey: CGColor
    var orange: CGColor
    var brown: CGColor
    
       // Prepare pen widths
    let thick = CGFloat(4.0)
    let standard = CGFloat(3.0)
    let thin = CGFloat(1.5)
    
    /// Transforms between model and screen space
    var modelToDisplay, displayToModel: CGAffineTransform?
    
    /// Do some of the setup only one time
    required init(coder aDecoder: NSCoder)  {
        
           // Prepare colors
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let blackComponents: [CGFloat] = [0.0, 0.0, 0.0, 1.0]
        black = CGColor(colorSpace: colorSpace, components: blackComponents)!
        let blueComponents: [CGFloat] = [0.0, 0.0, 1.0, 1.0]
        blue = CGColor(colorSpace: colorSpace, components: blueComponents)!
        let greenComponents: [CGFloat] = [0.0, 1.0, 0.0, 1.0]
        green = CGColor(colorSpace: colorSpace, components: greenComponents)!
        let greyComponents: [CGFloat] = [0.7, 0.7, 0.7, 1.0]
        grey = CGColor(colorSpace: colorSpace, components: greyComponents)!
        let orangeComponents: [CGFloat] = [1.0, 0.65, 0.0, 1.0]
        orange = CGColor(colorSpace: colorSpace, components: orangeComponents)!
        let brownComponents: [CGFloat] = [0.63, 0.33, 0.18, 1.0]
        brown = CGColor(colorSpace: colorSpace, components: brownComponents)!
        
        
        super.init(coder: aDecoder)!   // Done here to be able to use "self.bounds" for scaling below
        
        guard !modelGeo.displayCurves.isEmpty else {    // Bail if there isn't anything to plot
            print("Nothing to scale!")
            return
        }
        
        var brick = modelGeo.displayCurves.first!.getExtent()
        
        for (xedni, wire) in modelGeo.displayCurves.enumerated()  {
            
            if xedni > 0   {
                brick = brick + wire.getExtent()
            }
        }
        
        /// Bounding area for play
        let arena = CGRect(x: brick.getOrigin().x, y: brick.getOrigin().y, width: brick.getWidth(), height: brick.getHeight())
        
        /// Transforms to and from model coordinates
        let tforms = findScaleAndCenter(displayRect: self.bounds, subjectRect: arena)
        
        modelToDisplay = tforms.toDisplay
        displayToModel = tforms.toModel
        
    }
    
    
    /// Perform the plotting
    override func draw(_ rect: CGRect) {
        
        guard !modelGeo.displayCurves.isEmpty else {    // Bail if there isn't anything to plot
            return
        }
        
            // Preserve settings that were used before
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState();    // Preserve settings that were used before
        
        
        for wire in modelGeo.displayCurves   {    // Traverse through the entire collection
            
                // Choose the appropriate pen
            switch wire.usage  {
                
            case .arc:
                context.setStrokeColor(blue)
                context.setLineWidth(thick)
                context.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
                
            case .sweep:
                context.setStrokeColor(grey)
                context.setLineWidth(thin)
                context.setLineDash(phase: 0, lengths: [CGFloat(10), CGFloat(8)]);
                                
            case .extent:
                context.setStrokeColor(brown)
                context.setLineWidth(thin)
                context.setLineDash(phase: 5, lengths: [CGFloat(10), CGFloat(8)])    // To clear any previous dash pattern
                
            case .ideal:
                context.setStrokeColor(black)
                context.setLineWidth(thin)
                context.setLineDash(phase: 0, lengths: [CGFloat(3), CGFloat(3)])    // To clear any previous dash pattern
                
            case .approx:
                context.setStrokeColor(green)
                context.setLineWidth(standard)
                context.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
                
            default:
                context.setStrokeColor(black)
                context.setLineWidth(thin)
                context.setLineDash(phase: 0, lengths: []);    // To clear any previous dash pattern
                
            }
            
            
            wire.draw(context: context, tform: modelToDisplay!)
            
        }   // End of loop through the display list
        
        
        context.restoreGState();    // Restore prior settings
        
    }    // End of drawRect
    
    
    /// Determines parameters to center the model on the screen.
    /// - Parameter: displayRect: Bounds of the plotting area
    /// - Parameter: subjectRect: A CGRect that bounds the model space used
    /// - Returns: A tuple containing transforms between model and display space
    /// - Makes no checks to see that the CGRects are non-zero
    func  findScaleAndCenter(displayRect: CGRect, subjectRect: CGRect) -> (toDisplay: CGAffineTransform, toModel: CGAffineTransform)   {
        
        let rangeX = subjectRect.width
        let rangeY = subjectRect.height
        
        /// For an individual edge
        let margin = CGFloat(20.0)   // Measured in "points", not pixels, or model units
        let twoMargins = CGFloat(2.0) * margin
        
        let scaleX = (displayRect.width - twoMargins) / rangeX
        let scaleY = (displayRect.height - twoMargins) / rangeY
        
        let scale = min(scaleX, scaleY)
        
        
        // Find the middle of the model area for translation
        let giro = subjectRect.origin
        
        let middleX = giro.x + 0.5 * rangeX
        let middleY = giro.y + 0.5 * rangeY
        
        let transX = (displayRect.width - twoMargins) / 2 - middleX * scale + margin
        let transY = (displayRect.height - twoMargins) / 2 + middleY * scale + margin
        
        let modelScale = CGAffineTransform(scaleX: scale, y: -scale)   // To make Y positive upwards
        let modelTranslate = CGAffineTransform(translationX: transX, y: transY)
        
        
        /// The combined matrix based on the plot parameters
        let modelToDisplay = modelScale.concatenating(modelTranslate)
        
        /// Useful for interpreting screen picks
        let displayToModel = modelToDisplay.inverted()
        
        return (modelToDisplay, displayToModel)
    }
    
}
