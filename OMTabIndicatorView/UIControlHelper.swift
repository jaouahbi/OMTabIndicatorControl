//
//  UIControlHelper.swift
//
//  Created by Jorge Ouahbi on 24/09/2020.
//

import UIKit

extension UIColor {
    convenience init(_ hex: UInt) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    convenience init(hex: UInt) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    convenience init(_ hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    func isLight() -> Bool {
        guard let components = cgColor.components,
            components.count >= 3 else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return !(brightness < 0.5)
    }
    
    public var complementaryColor: UIColor {
        if #available(iOS 13, tvOS 13, *) {
            return UIColor { traitCollection in
                return self.isLight() ? self.darker : self.lighter
            }
        } else {
            return isLight() ? darker : lighter
        }
    }
    
    public var lighter: UIColor {
        return adjust(by: 1.35)
    }
    
    public var darker: UIColor {
        return adjust(by: 0.94)
    }
    
    func adjust(by percent: CGFloat) -> UIColor {
        var hue: CGFloat = 0,
        saturation: CGFloat = 0,
        brightness: CGFloat = 0,
        alpha: CGFloat = 0
        getHue(&hue,
               saturation: &saturation,
               brightness: &brightness,
               alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness * percent, alpha: alpha)
    }
    
    func makeGradient() -> [UIColor] {
        return [self, self.complementaryColor, self]
    }
}

public extension UIColor {
    static var greenSea     = UIColor(0x16a085)
    static var turquoise    = UIColor(0x1abc9c)
    static var emerald      = UIColor(0x2ecc71)
    static var peterRiver   = UIColor(0x3498db)
    static var amethyst     = UIColor(0x9b59b6)
    static var wetAsphalt   = UIColor(0x34495e)
    static var nephritis    = UIColor(0x27ae60)
    static var belizeHole   = UIColor(0x2980b9)
    static var wisteria     = UIColor(0x8e44ad)
    static var midnightBlue = UIColor(0x2c3e50)
    static var sunFlower    = UIColor(0xf1c40f)
    static var carrot       = UIColor(0xe67e22)
    static var alizarin     = UIColor(0xe74c3c)
    static var clouds       = UIColor(0xecf0f1)
    static var darkClouds   = UIColor(0x1c2325)
    static var concrete     = UIColor(0x95a5a6)
    static var flatOrange   = UIColor(0xf39c12)
    static var pumpkin      = UIColor(0xd35400)
    static var pomegranate  = UIColor(0xc0392b)
    static var silver       = UIColor(0xbdc3c7)
    static var asbestos     = UIColor(0x7f8c8d)
}

class UIControlHelper {
    class func drawInnerShadow( ctx: CGContext,
                                bounds: CGRect,
                                shadowRadius: CGFloat,
                                shadowEdgeMask: UInt,
                                color: UIColor?) {
        ctx.clear(bounds);
        let rect = bounds.insetBy(dx:-4*shadowRadius, dy: -4*shadowRadius)
        ctx.addRect(rect);
        
        // Set up a path outside our bounds so the shadow will be cast into the bounds but no fill.  Push each edge out based on whether we want a shadow on that edge.  If we do,
        var interiorRect = bounds;
        let noShadowOutset = 2*shadowRadius;
        
        if ((shadowEdgeMask & (1<<CGRectEdge.minXEdge.rawValue)) == 0) {
            interiorRect.origin.x -= noShadowOutset;
            interiorRect.size.width += noShadowOutset;
        }
        if ((shadowEdgeMask & (1<<CGRectEdge.minYEdge.rawValue)) == 0) {
            interiorRect.origin.y -= noShadowOutset;
            interiorRect.size.height += noShadowOutset;
        }
        if ((shadowEdgeMask & (1<<CGRectEdge.maxXEdge.rawValue)) == 0) {
            interiorRect.size.width += noShadowOutset;
        }
        if ((shadowEdgeMask & (1<<CGRectEdge.maxYEdge.rawValue)) == 0) {
            interiorRect.size.height += noShadowOutset;
        }
        ctx.addRect(interiorRect)
        
        let defaultColor = UIColor(white: 0, alpha: 0.8)
        
        let shadowColor = color != nil ? color?.withAlphaComponent(0.8) ?? defaultColor : defaultColor
        
        ctx.setShadow(offset: CGSize(width: 0, height: 2),
                      blur: shadowRadius,
                      color: shadowColor.cgColor)
        
        ctx.setFillColor(gray: 0, alpha: 8)
        ctx.drawPath(using: .eoFill)
    }
    
    class func  createShadowImageWithSize( size: CGSize,
                                           shadowRadius: CGFloat,
                                           shadowEdgeMask: UInt,
                                           color: UIColor?) -> CGImage?
    {
        assert(size.width >= 1);
        assert(size.height >= 1);
        let componentCount: CGFloat = 4;
        let alphaInfo: CGImageAlphaInfo = .premultipliedFirst;
        let pixelsWide = ceil(size.width);
        let pixelsHigh = ceil(size.height);
        let bytesPerRow = componentCount * pixelsWide; // alpha
        
        // We can cast directly from CGImageAlphaInfo to CGBitmapInfo because the first component in the latter is an alpha info mask
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: nil,
                                  width: Int(pixelsWide),
                                  height: Int(pixelsHigh),
                                  bitsPerComponent: 8,
                                  bytesPerRow: Int(bytesPerRow),
                                  space: colorSpace,
                                  bitmapInfo: alphaInfo.rawValue) else {
                                    return nil;
                                    
        }
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        drawInnerShadow(ctx: ctx, bounds: bounds, shadowRadius: shadowRadius, shadowEdgeMask: shadowEdgeMask, color: color);
        ctx.flush()
        let shadowImage = ctx.makeImage()
        return shadowImage;
    }
}

extension UIView {
    func adjustLayoutToSuperview( trailing: CGFloat = 0,
                                  leading: CGFloat = 0,
                                  botton: CGFloat = 0,
                                  top: CGFloat = 0) {
        guard let superview = superview else {
            print("The view must has a superview.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingAnchor = superview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing)
        let leadingAnchor = superview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading)
        let topAnchor = superview.topAnchor.constraint(equalTo: self.topAnchor, constant: top)
        let bottomAnchor = superview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: botton)
        NSLayoutConstraint.activate([trailingAnchor, leadingAnchor, topAnchor, bottomAnchor])
        
    }
    /// fixedAnchorSize
    /// - Parameters:
    ///   - width: GCFloat
    ///   - height: GCFloat
    func fixedAnchorSize(width: CGFloat = 0, height: CGFloat = 0) {
        //        guard superview != nil else {
        //            GCDebugManager.assertionFailureEx("The view must has a superview.")
        //            return
        //        }
        self.translatesAutoresizingMaskIntoConstraints = false
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    func centerXY() {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let superview = self.superview else { return  }
        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }
    func centerX() {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let superview = self.superview else { return  }
        self.centerXAnchor.constraint(equalTo:superview.centerXAnchor).isActive = true
    }
    func centerY() {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let superview = self.superview else { return  }
        self.centerYAnchor.constraint(equalTo:superview.centerYAnchor).isActive = true
    }
}
