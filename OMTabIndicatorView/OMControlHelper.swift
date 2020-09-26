//
//  OMControlHelper.swift
//
//  Created by Jorge Ouahbi on 24/09/2020.
//

import UIKit


extension CGRect {
    var topCenter: CGPoint { return CGPoint(x: self.midX, y: 0.0) }
    var bottomCenter: CGPoint { return CGPoint(x: self.midX, y: self.size.height) }
}

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

// https://stackoverflow.com/questions/37055755/computing-complementary-triadic-tetradic-and-analagous-colors
extension UIColor {
    var splitComplement: [UIColor] {
        return [splitComplement0, splitComplement1]
    }
    var triadic: [UIColor] {
        return [triadic0, triadic1]
    }
    var tetradic: [UIColor] {
        return [tetradic0, tetradic1, tetradic2]
    }
    var analagous: [UIColor] {
        return [analagous0, analagous1]
    }
    var complement: UIColor {
        return self.withHueOffset(0.5)
    }
    var splitComplement0: UIColor {
        return self.withHueOffset(150 / 360)
    }
    var splitComplement1: UIColor {
        return self.withHueOffset(210 / 360)
    }
    var triadic0: UIColor {
        return self.withHueOffset(120 / 360)
    }
    var triadic1: UIColor {
        return self.withHueOffset(240 / 360)
    }
    var tetradic0: UIColor {
        return self.withHueOffset(0.25)
    }
    var tetradic1: UIColor {
        return self.complement
    }
    var tetradic2: UIColor {
        return self.withHueOffset(0.75)
    }
    var analagous0: UIColor {
        return self.withHueOffset(-1 / 12)
    }
    var analagous1: UIColor {
        return self.withHueOffset(1 / 12)
    }
    func withHueOffset(_ offset: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: fmod(h + offset, 1), saturation: s, brightness: b, alpha: a)
    }
}

extension UIColor {
    // get a complementary color to this color:
    static func complementaryForColor(_ color: UIColor) -> UIColor {
        let ciColor = CIColor(color: color)
        // get the current values and make the difference from white:
        let compRed: CGFloat = 1.0 - ciColor.red
        let compGreen: CGFloat = 1.0 - ciColor.green
        let compBlue: CGFloat = 1.0 - ciColor.blue
        return UIColor(red: compRed,
                       green: compGreen,
                       blue: compBlue,
                       alpha: 1.0)
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
    static var greyishBlue  = UIColor(0x5987a4)
    
    static var navyThree    = UIColor(0x001825)
    static var navyTwo    = UIColor(0x002941)
    static var navy    = UIColor(0x012336)
    
    static var paleGrey     = UIColor(0xf7f7fa)
    static var paleGreyTwo  = UIColor(0xededf2)
    static var paleGreyThree  = UIColor(0xeeeef3)

}

class OMControlHelper {
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
    
    class func  createShadowImage( with size: CGSize,
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
    
    func adjustLeftRightLayoutToSuperview( left: CGFloat = 0, right: CGFloat = 0) {
        guard let superview = superview else {
            print("The view must has a superview.")
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: left).isActive = true
        superview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right).isActive = true

    }
    
    /// fixedAnchorSize
    /// - Parameters:
    ///   - width: GCFloat
    ///   - height: GCFloat
    func fixedAnchorSize(width: CGFloat = 0, height: CGFloat = 0) {
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
        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
    }
    func centerY() {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let superview = self.superview else { return  }
        self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }
}


/*
 let layer = CAShapeLayer()

 // Setup layer...

 // Gradient Direction: →
 let gradientLayer1 = layer.applyGradient(of: UIColor.yellow, UIColor.red, at: 0)

 // Gradient Direction: ↗︎
 let gradientLayer2 = layer.applyGradient(of: UIColor.purple, UIColor.yellow, UIColor.green, at: -45)

 // Gradient Direction: ←
 let gradientLayer3 = layer.applyGradient(of: UIColor.yellow, UIColor.blue, UIColor.green, at: 180)

 // Gradient Direction: ↓
 let gradientLayer4 = layer.applyGradient(of: UIColor.red, UIColor.blue, at: 450)
 Mathematical Explanation

 So I actually just recently spent a lot of time trying to answer this myself. Here are some example angles just to help understand and visualize the clockwise direction of rotation.

 Example Angles

 If you are interested in how I figured it out, I made a table to visualize essentially what I am doing from 0° - 360°.

 Table
 share  improve this answer   follow
 answered Jan 26 '19 at 0:20

 Noah Wilder

 https://stackoverflow.com/questions/41019686/how-to-fill-a-cashapelayer-with-an-angled-gradient
 */

public extension CALayer {

    func applyGradient(of colors: UIColor..., atAngle angle: CGFloat) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        gradientLayer.calculatePoints(for: angle)
        self.insertSublayer(gradientLayer, at:0)
        return gradientLayer
    }
    func applyFadeGradient(of colors: UIColor..., fadePercent: CGFloat) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0 - fadePercent)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.frame = frame
        self.insertSublayer(gradientLayer, at:0)
        return gradientLayer
    }
    func applyFadeGradient(colors: [CGColor], fadePercent: CGFloat) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0 - fadePercent)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.frame = frame
        self.insertSublayer(gradientLayer, at:0)
        return gradientLayer
    }
}

extension CALayer {
    var image: CGImage? {
        let width = Int(frame.size.width)
        let height = Int(frame.size.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let rawData = malloc(height * bytesPerRow)
        let bitsPerComponent = 8
        guard let context = CGContext(data: rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
                        return nil
        }
        // Before you render the layer check if the layer turned over.
        if contentsAreFlipped() {
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: frame.size.height)
            context.concatenate(flipVertical)
        }
        render(in: context)
        return context.makeImage()
    }
}

typealias GradientColors = (UIColor, UIColor)

 extension CAShapeLayer {
    func mask(with rect: CGRect,
              cornerRadius: CGFloat = 0,
              inverse: Bool = false) {
        let path = cornerRadius > 0 ?
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius) :
            UIBezierPath(rect: rect)
        let maskLayer = CAShapeLayer()
        if inverse {
            path.append(UIBezierPath(rect: bounds))
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        maskLayer.path = path.cgPath
        self.mask = maskLayer
    }
}



// Layer with clip path
class OMShapeLayerClipPath: CAShapeLayer {
    func addPathAndClipIfNeeded(ctx: CGContext) {
        if let path = self.path {
            ctx.addPath(path)
            if self.strokeColor != nil {
                ctx.setLineWidth(self.lineWidth)
                ctx.replacePathWithStrokedPath()
            }
            ctx.clip()
        }
    }
    override public func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        addPathAndClipIfNeeded(ctx: ctx)
    }
}
// Shape layer with clip path and gradient friendly
class OMGradientShapeClipLayer: OMShapeLayerClipPath {
    
    // Some predefined Gradients
    var gardientColor: UIColor = .clear
    public lazy var insetGradient: GradientColors =  {
        return  (UIColor(red:0 / 255.0, green:0 / 255.0,blue: 0 / 255.0,alpha: 0 ),
                 UIColor(red: 0 / 255.0, green:0 / 255.0,blue: 0 / 255.0,alpha: 0.2 ))
    }()
    public lazy var shineGradient: GradientColors =  {
        return  (UIColor(red:1, green:1,blue: 1,alpha: 0 ),
                 UIColor(red:1, green:1,blue:1,alpha: 0.8 ))
    }()
    public lazy var shadowGradient: GradientColors =  {
        return  (UIColor(red:0, green:0,blue: 0,alpha: 0 ),
                 UIColor(red:0, green:0,blue: 0,alpha: 0.6 ))
    }()
    public lazy var shadeGradient: GradientColors =  {
        return  (UIColor(red: 252 / 255.0, green: 252 / 255.0,blue: 252 / 255.0,alpha: 0.65 ),
                 UIColor(red:  178 / 255.0, green:178 / 255.0,blue: 178 / 255.0,alpha: 0.65 ))
    }()
    public lazy var convexGradient: GradientColors =  {
        return  (UIColor(red:1,green:1,blue:1,alpha: 0.43 ),
                 UIColor(red:1,green:1,blue:1,alpha: 0.5 ))
    }()
    public lazy var concaveGradient: GradientColors =  {
        return  (UIColor(red:1.0,green:1,blue:1,alpha: 0.0 ),
                 UIColor(red:1,green:1,blue:1,alpha: 0.46 ))
    }()
    public lazy var glossGradient: GradientColors =  {
        return  (UIColor(red:1.0,green:1.0,blue:1.0,alpha: 0.35 ),
                 UIColor(red:1.0,green:1.0,blue:1.0,alpha: 0.6 ))
        
    }()
}

public extension CAGradientLayer {

    /// Sets the start and end points on a gradient layer for a given angle.
    ///
    /// - Important:
    /// *0°* is a horizontal gradient from left to right.
    ///
    /// With a positive input, the rotational direction is clockwise.
    ///
    ///    * An input of *400°* will have the same output as an input of *40°*
    ///
    /// With a negative input, the rotational direction is clockwise.
    ///
    ///    * An input of *-15°* will have the same output as *345°*
    ///
    /// - Parameters:
    ///     - angle: The angle of the gradient.
    ///
    func calculatePoints(for angle: CGFloat) {


        var ang = (-angle).truncatingRemainder(dividingBy: 360)

        if ang < 0 { ang = 360 + ang }

        let n: CGFloat = 0.5

        let tanx: (CGFloat) -> CGFloat = { tan($0 * CGFloat.pi / 180) }

        switch ang {

        case 0...45, 315...360:
            let a = CGPoint(x: 0, y: n * tanx(ang) + n)
            let b = CGPoint(x: 1, y: n * tanx(-ang) + n)
            startPoint = a
            endPoint = b

        case 45...135:
            let a = CGPoint(x: n * tanx(ang - 90) + n, y: 1)
            let b = CGPoint(x: n * tanx(-ang - 90) + n, y: 0)
            startPoint = a
            endPoint = b

        case 135...225:
            let a = CGPoint(x: 1, y: n * tanx(-ang) + n)
            let b = CGPoint(x: 0, y: n * tanx(ang) + n)
            startPoint = a
            endPoint = b

        case 225...315:
            let a = CGPoint(x: n * tanx(-ang - 90) + n, y: 0)
            let b = CGPoint(x: n * tanx(ang - 90) + n, y: 1)
            startPoint = a
            endPoint = b

        default:
            let a = CGPoint(x: 0, y: n)
            let b = CGPoint(x: 1, y: n)
            startPoint = a
            endPoint = b

        }
    }
}

func CreateVerticalGradientImage( gradient: CGGradient,
                                  height: size_t,
                                  opaque: Bool,
                                  flip: Bool,
                                  colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()) -> CGImage?
{
    let width: size_t = 1;
    var componentCount: size_t  = colorSpace.numberOfComponents;
    var alphaInfo: CGImageAlphaInfo
    var gradientColorSpace = colorSpace
    if (opaque) {
        alphaInfo = CGImageAlphaInfo.none;
    } else {
        // gray+alpha isn't supported, but alpha-only is (seem to be {black,alpha}). Unclear if you can make it {white,alpha} or any generic color).  Sadly, at least in some cases alpha-only seems to have some weird issues (see OQHoleLayer). So, upsample to RGBA.
      
        gradientColorSpace = CGColorSpaceCreateDeviceRGB()
        componentCount = 4;
        alphaInfo = CGImageAlphaInfo.premultipliedFirst;
    }
    
    // We can cast directly from CGImageAlphaInfo to CGBitmapInfo because the first component in the latter is an alpha info mask
    let bytesPerRow = componentCount * width;
    
    guard let ctx = CGContext(data: nil,
                                  width: Int(width),
                                  height: Int(height),
                                  bitsPerComponent: 8,
                                  bytesPerRow: Int(bytesPerRow),
                                  space: gradientColorSpace,
                                  bitmapInfo: alphaInfo.rawValue) else {
                                    return nil;
                                    
        }
   
    let bounds = CGRect(x: 0, y: 0, width: width, height: height);
    ctx.addRect(bounds);
    ctx.clip();
    
    var startPoint = bounds.origin;
    var endPoint   = CGPoint(x: bounds.minX, y: bounds.maxY)
    
    if (flip) {
        let temp = startPoint
        startPoint = endPoint
        endPoint = temp
    }
    ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: []);
    ctx.flush();
    let gradientImage = ctx.makeImage();
    return gradientImage;
}

func CreateVerticalGrayGradient( minGray: CGFloat, maxGray: CGFloat) -> CGGradient?
{
    let minGrayColorRef = UIColor(white: minGray, alpha: 1.0);
    let maxGrayColorRef = UIColor(white: maxGray, alpha: 1.0)
    let colorSpace = CGColorSpaceCreateDeviceGray();
    let gradient = CGGradient(colorsSpace: colorSpace, colors: [minGrayColorRef, maxGrayColorRef] as CFArray, locations: nil)
    return gradient
}

extension CGAffineTransform {
     func shear(_ xShear: CGFloat, yShear: CGFloat) -> CGAffineTransform {
        var transform = self
        transform.c = -xShear
        transform.b = yShear
        return transform
    }
    static func shearX(_ xShear: CGFloat = 0.3) -> CGAffineTransform  {
       return CGAffineTransform(a: 1, b: 0, c: xShear, d: 1, tx: 0, ty: 0)
    }
    static func shearY(_ yShear: CGFloat = 0.3) -> CGAffineTransform  {
       return CGAffineTransform(a: 1, b: yShear, c: 0, d: 1, tx: 0, ty: 0)
    }
    static func shear( xShear: CGFloat,  yShear: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(a: 1, b: yShear, c: xShear, d: 1, tx: 0, ty: 0);
    }
}
