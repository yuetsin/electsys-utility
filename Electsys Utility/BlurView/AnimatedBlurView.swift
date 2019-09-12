//
//  AnimatedBlurView.swift
//  AnimatedBlurView
//
//  Created by yuetsin on 2019/7/25.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Cocoa
import QuartzCore

@IBDesignable
class AMBlurView: NSView {

    static let defaultAlphaValue: CGFloat = 0.7
    static let defaultBlurRadius: Double = 20.0
    static let defaultSaturationFactor: Double = 2.0

    private lazy var blurFilter: CIFilter? = {
        let blurredFilter = CIFilter(name: "CIGaussianBlur")
        blurredFilter?.setValue(self.blurRadius, forKey: "inputRadius")
        return blurredFilter
    }()

    private lazy var saturationFilter: CIFilter? = {
        let saturationFilter = CIFilter(name: "CIColorControls")
        saturationFilter?.setValue(self.saturationFactor, forKey: "inputSaturation")
        return saturationFilter
    }()

    var hostedLayer: CALayer?
    
    @IBInspectable
    var transparencyAlpha: CGFloat = defaultAlphaValue {
        didSet {
            layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(transparencyAlpha).cgColor
            needsDisplay = true
            if transparencyAlpha < 0.0 {
                transparencyAlpha = 0.0
            } else if transparencyAlpha > 1.0 {
                transparencyAlpha = 1.0
            }
        }
    }

    @IBInspectable
    var saturationFactor: Double = defaultBlurRadius {
        didSet {
            saturationFilter?.setValue(saturationFactor, forKey: "inputSaturation")
            needsDisplay = true
//            resetFilters()
            if saturationFactor < 0.0 {
                saturationFactor = 0.0
            }
        }
    }

    @IBInspectable
    var blurRadius: Double = defaultSaturationFactor {
        didSet {
            blurFilter?.setValue(blurRadius, forKey: "inputRadius")
            needsDisplay = true
//            resetFilters()
            if blurRadius < 0.0 {
                blurRadius = 0.0
            }
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    override var acceptsFirstResponder: Bool {
        return false
    }

    func setBlurRadius(blurRadius radius: Double) {
        // Setting the blur radius requires a resetting of the filters
        blurRadius = radius
        resetFilters()
    }

    func setSaturationFactor(saturationFactor factor: Double) {
        // Setting the saturation factor also requires a resetting of the filters
        saturationFactor = factor
        resetFilters()
    }

    func setUp() {
        // Instantiate a new CALayer and set it as the NSView's layer (layer-hosting)
        hostedLayer = CALayer()
        wantsLayer = true

        layer = hostedLayer
        layer?.masksToBounds = true

        // Set the layer to redraw itself once it's size is changed
        layer?.needsDisplayOnBoundsChange = true

        // Initially create the filter instances
        resetFilters()
    }
    
    override func updateLayer() {
        layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(transparencyAlpha).cgColor
        needsDisplay = true
    }


    func resetFilters() {
        // To get a higher color saturation, we create a ColorControls filter
        guard saturationFilter != nil else {
            return
        }
        
        // Next, we create the blur filter
        guard blurFilter != nil else {
            return
        }

        // Now we apply the two filters as the layer's background filters
        layer?.backgroundFilters = [saturationFilter!, blurFilter!]

        layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: alphaValue).cgColor
        // ... and trigger a refresh
        layer?.setNeedsDisplay()
    }

    func animateBlurRadius(to blurRaius: Double, duration: Double = 0.25) {

    }
}
