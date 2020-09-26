import UIKit
extension UITableView {
    // 1.
    func setTableHeaderView(headerView: UIView, size: CGSize) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.tableHeaderView = headerView
      
        // ** Must setup AutoLayout after set tableHeaderView.
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerView.fixedAnchorSize(width: size.width, height: size.height)
    }
    // 2.
    func shouldUpdateHeaderViewFrame() -> Bool {
        guard let headerView = self.tableHeaderView else { return false }
        let oldSize = headerView.bounds.size
        // Update the size
        headerView.layoutIfNeeded()
        let newSize = headerView.bounds.size
        return oldSize != newSize
    }
}



extension UIView {
    func shear(_ shearValue: CGFloat = 0.3) {
        let shearTransform = CGAffineTransform(a: 1, b: 0, c: shearValue, d: 1, tx: 0, ty: 0)
        self.transform = shearTransform
    }
    static func shearTransform(_ transform: CGAffineTransform, xShear: CGFloat, yShear: CGFloat) -> CGAffineTransform {
        var transform = transform
        transform.c = -xShear
        transform.b = yShear
        return transform
    }
    static func makeShear( xShear: CGFloat,  yShear: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(a: 1, b: yShear, c: xShear, d: 1, tx: 0, ty: 0);
    }
}
protocol OMTabIndicatorViewDelegate: class {
    func didSelectedItem(at index: Int)
    func willSelectedItem(at index: Int)
}
final class OMTabIndicatorView: UIView {
    // MARK: Init and deinit
    init(_ items: [String], frame: CGRect) {
        super.init(frame: frame)
        configure(with: items)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Properties
    weak var delegate: OMTabIndicatorViewDelegate?
    private var items = [String]()
    private var itemLabels = [UILabel]()
    private(set) var selectedItemIndex = 0 {
        didSet {
            selectedItem(at: selectedItemIndex)
        }
    }
    // MARK: UI
    private let contentStackView = UIStackView()
    var selectionMarker: UIView = UIView()
    private let selectionLine = UIView()
    private let line = UIView()
    var fadeGradientMask: CAGradientLayer?
    var isShadowImage: Bool = true
    var isAnimatable: Bool = false
    var isVertical: Bool = true
    
    var glossGradientColor: UIColor  = .paleGreyThree
//    var shadowGradientColor: UIColor = .yellow
    var lineGradientColor: UIColor  = .greyishBlue
    var fadeGradientColor: UIColor  = .paleGreyTwo
    var selectedTextColor: UIColor  = .navyThree
    var selectedLineColor: UIColor  = .navyThree
    var markerColor: UIColor = .silver
    
    var selectedTextFont: UIFont = UIFont.boldSystemFont(ofSize: 13)
    var unselectedTextColor: UIColor  {return .greyishBlue }
 
    var unselectedTextFont: UIFont = UIFont.systemFont(ofSize: 12.5, weight: .regular)
    var unselectedLineColor: UIColor  {return .navyTwo }
    
    
    var animationDuration: TimeInterval = 0.5
    var shearAffineTransform: CGAffineTransform = shearTransform(CGAffineTransform(scaleX: 1.1, y: 1), x: 0.5, y: 0)
    var touchDownTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.2)
    var touchUpTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.7)
    var lineMarkHeight: CGFloat = 3
    
    // MARK: Functions
    private func configure(with items: [String]) {
        self.items = items
        itemLabels = items.enumerated().map { idx, item in
            let label = UILabel()
            label.text = item
            label.font = unselectedTextFont
            label.textColor = unselectedTextColor
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.isUserInteractionEnabled = true
            label.tag = idx
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTabItem))
            label.addGestureRecognizer(tapGesture)
            return label
        }

        configureStackView()
        setupSelectionView()
        selectedItemIndex = 0
        self.backgroundColor = .clouds
        
    }
    private func configureStackView() {
        addSubview(contentStackView)
        contentStackView.adjustLayoutToSuperview()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fillEqually
        itemLabels.forEach { contentStackView.addArrangedSubview($0) }
    }
    var fadeGardientColors: [CGColor] {
        return [fadeGradientColor.withAlphaComponent(1.0).cgColor,
                fadeGradientColor.withAlphaComponent(0.0).cgColor]
    }
//    private lazy var shadowGradientLayer: CAGradientLayer = {
//        // Create the gradient layer
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = shadowGradientColors
//        self.layer.insertSublayer(gradientLayer, at:0)
//        return gradientLayer
//    }()
    var lineGradientColors: [CGColor] {
        let gradient = lineGradientColor.makeGradient()
        return gradient.enumerated().map{$1.withAlphaComponent($0 == 0 ? 0.1 : 1.0).cgColor}
    }
    private lazy var lineMarkerGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = lineGradientColors
        selectionLine.layer.insertSublayer(gradientLayer, at:0)
        return gradientLayer
    }()
//    var shadowGradientColors: [CGColor] {
//        var red: CGFloat = 0,
//        green: CGFloat = 0,
//        blue: CGFloat = 0,
//        alpha: CGFloat = 0
//        var componentsShadowGradient: [UIColor] = [UIColor.black.withAlphaComponent(0.0),
//                                                   UIColor.black.withAlphaComponent(0.6)]
//        if shadowGradientColor.getRed(&red,
//                           green: &green,
//                           blue: &blue,
//                           alpha: &alpha) {
//            componentsShadowGradient = [UIColor(red: red, green:green, blue:blue, alpha: 0),
//                                        UIColor(red: red, green:green, blue:blue, alpha: 0.6)]
//
//        }
//        return componentsShadowGradient.map{$0.cgColor}
//    }
    var glossGradientColors: [CGColor] {
        let gradient =  [glossGradientColor.withAlphaComponent(0.35),
                          glossGradientColor.withAlphaComponent(0.06)]
        return gradient.map{$0.cgColor}
    }
    private lazy var markerGlossLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = glossGradientColors
        selectionMarker.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    
    private lazy var markerClipGlossLayer: OMShapeLayerClipPath = {
        let gradientLayer = OMShapeLayerClipPath()
        markerGlossLayer.mask = gradientLayer
        return gradientLayer
    }()
    
    var fadePercent: CGFloat = 0.2
    fileprivate func renderGloss() {
        markerGlossLayer.colors      = glossGradientColors
        markerGlossLayer.frame       = CGRect(origin: .zero, size:CGSize( width: selectionMarker.frame.width,
                                                                          height: selectionMarker.frame.height / 2))
        markerGlossLayer.startPoint  = CGPoint(x: selectionMarker.frame.minX, y: selectionMarker.frame.maxY)
        markerGlossLayer.endPoint    = CGPoint(x: selectionMarker.frame.minX, y: selectionMarker.frame.maxY)
        let clipRect = markerGlossLayer.bounds
        markerClipGlossLayer.path = UIBezierPath(rect: clipRect).cgPath
    }
//    fileprivate func renderShadow() {
//        shadowGradientLayer.colors          = lineGradientColors
//        shadowGradientLayer.frame           = bounds
//        shadowGradientLayer.locations       = [0.0 ,0.1]
//        shadowGradientLayer.startPoint      = shadowGradientLayer.frame.origin
//        shadowGradientLayer.endPoint        = CGPoint(x: shadowGradientLayer.frame.maxX,y: shadowGradientLayer.frame.maxY)
//    }
    fileprivate func renderLine() {
        lineMarkerGradientLayer.colors    = lineGradientColors
        lineMarkerGradientLayer.locations = [0.0 ,0.1, 1.0]
        lineMarkerGradientLayer.frame     = self.selectionLine.bounds
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
     
        renderLine()
        renderGloss()
//        renderShadow()
//
//        fadeGradientMask = selectionMarker.layer.applyFadeGradient(colors: fadeGardientColors,
//                                                                   fadePercent: fadePercent)
        
        CATransaction.commit()
    }
    
    var lineMargin: CGFloat = 20
    private func setupSelectionView() {
        addSubview(selectionMarker)
        addSubview(selectionLine)
        addSubview(line)
        selectionLine.layer.cornerRadius    = lineMarkHeight / 2
        selectionLine.layer.masksToBounds   = false
        //selectionMarker.isHidden = true
        if let itemLabel = itemLabels.first {
            selectionMarker.translatesAutoresizingMaskIntoConstraints = false
            selectionMarker.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            selectionMarker.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            itemLabel.leftAnchor.constraint(equalTo: selectionMarker.leftAnchor, constant: 0).isActive  = true
            itemLabel.rightAnchor.constraint(equalTo: selectionMarker.rightAnchor, constant: 0).isActive  = true

           selectionLine.translatesAutoresizingMaskIntoConstraints = false
           selectionLine.leftAnchor.constraint(equalTo: selectionMarker.leftAnchor, constant: 0).isActive = true
           selectionLine.rightAnchor.constraint(equalTo: selectionMarker.rightAnchor, constant: 0).isActive = true
           selectionLine.bottomAnchor.constraint(equalTo: selectionMarker.bottomAnchor, constant: 0).isActive = true
           selectionLine.fixedAnchorSize(width: 0, height: lineMarkHeight)

           line.translatesAutoresizingMaskIntoConstraints = false
           line.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
           line.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
           line.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
           line.fixedAnchorSize(width: 0, height: lineMarkHeight)
        }
        sendSubviewToBack(selectionMarker)
        selectionMarker.backgroundColor = .clear
        sendSubviewToBack(selectionLine)
        selectionLine.layer.backgroundColor = selectedLineColor.cgColor
        sendSubviewToBack(line)
        line.layer.backgroundColor = unselectedLineColor.cgColor
        self.layoutIfNeeded()
        
        if isShadowImage {
            let markHeight: CGFloat = selectionMarker.bounds.size.height - lineMarkHeight
            let selectionSize = CGSize(width: selectionMarker.bounds.size.width, height: markHeight)
            let shadowEdgeMask: UInt = UInt( CGRectEdge.maxXEdge.rawValue |
                CGRectEdge.maxYEdge.rawValue |
                CGRectEdge.minXEdge.rawValue |
                CGRectEdge.minYEdge.rawValue)
            if let shadowImage = OMControlHelper.createShadowImage(with: selectionSize,
                                                                    shadowRadius: 20,
                                                                    shadowEdgeMask: shadowEdgeMask,
                                                                    color: markerColor) {
                selectionMarker.backgroundColor = UIColor(patternImage: UIImage(cgImage: shadowImage))
                //selectionMarker.transform = self.shearAffineTransform
            }
        }
    }
    class private func shearTransform(_ transform: CGAffineTransform, x: CGFloat, y: CGFloat) -> CGAffineTransform {
        var transform = transform
        transform.c = -x
        transform.b = y
        return transform
    }
    @objc private func didTapTabItem(_ tapGesture: UITapGestureRecognizer) {
        if let view = tapGesture.view {
            selectedItemIndex = view.tag
            delegate?.didSelectedItem(at: selectedItemIndex)
        }
    }
    func willSelecteItemAtIndex( at index: Int) {
        delegate?.willSelectedItem(at: index)
        itemLabels.forEach(unselectItem)
        let label       = itemLabels[index]
        label.font      = selectedTextFont
        label.textColor = selectedTextColor
    }
    fileprivate func animateStepTwo() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseOut],  animations: {
                        self.selectionMarker.transform = CGAffineTransform.identity.concatenating(self.touchDownTransform)
                        self.selectionLine.transform = CGAffineTransform.identity.concatenating(self.touchDownTransform)
        }, completion: { complete in
            if complete {
                UIView.animate(withDuration: 2.5,
                               delay: 0,
                               usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0.8,
                               options: [.curveLinear],  animations: {
                                self.selectionMarker.transform = CGAffineTransform.identity
                                self.selectionLine.transform = CGAffineTransform.identity
                })
                
            }
        })
    }
    
    private func selectedItem(at index: Int) {
        // get the selection
        print("selectedItem: \(index)")
        layoutIfNeeded()
        let targetLabel = itemLabels[index]
        targetLabel.layer.borderColor = UIColor.black.cgColor
        targetLabel.layer.borderWidth = 2
        // notify about the selection change
        willSelecteItemAtIndex(at: index)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseIn],
                       animations: {
                        if self.isAnimatable {
                            self.selectionMarker.layer.setAffineTransform(self.shearAffineTransform.concatenating(self.touchUpTransform))
                            self.selectionLine.layer.setAffineTransform(self.selectionLine.transform.concatenating(self.touchUpTransform))
                        }
                        self.selectionMarker.center = CGPoint(x: targetLabel.center.x,
                                                                  y: self.selectionMarker.center.y)
                        self.selectionLine.center = CGPoint(x: targetLabel.center.x,
                                                       y: self.selectionLine.center.y)
        }, completion: { complete in
            if complete {
                if self.isAnimatable {
                    self.animateStepTwo()
                }
            }
        })
        //      UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [],  animations: {
        //            self.lineView.transform = index > 0 ?
        //                self.lineView.transform.translatedBy(x: targetLabel.frame.minX, y: 0) :
        //                CGAffineTransform.identity
        //             self.tabSelectionMarkerView.transform = index > 0 ?
        //            self.tabSelectionMarkerView.transform.translatedBy(x: targetLabel.frame.minX, y: 0):
        //                self.shearTransform(CGAffineTransform(scaleX: 1.1, y: 1), x: 0.5, y: 0)
        //            self.layoutIfNeeded()
        //        })
    }
    //        // animnate the selction
    //        CATransaction.begin()
    //        UIView.animate(withDuration: animationDuration, animations: {
    ////            let minXTargetLabel = targetLabel.frame.minX
    ////            if index == 0 {
    ////                // Set the on touch transform
    ////                targetLabel.transform = self.touchTransform
    ////                // Reset the marks transforms
    ////                self.tabSelectionMarkerView.transform = CGAffineTransform.identity
    ////                self.lineView.transform   = CGAffineTransform.identity
    ////            } else {
    ////                // Move the line mark
    ////                self.lineView.transform = self.lineView.transform.translatedBy(x: minXTargetLabel, y: 0)
    ////                // Set the on touch transform
    ////                targetLabel.transform   = self.touchTransform
    ////            }
    //        }, completion: { completed in
    //            if completed {
    //                targetLabel.transform = CGAffineTransform.identity
    //            }
    //        })
    //        CATransaction.commit()
    //   }
    private func unselectItem(_ label: UILabel) {
        label.font = unselectedTextFont
        label.textColor = unselectedTextColor
        label.backgroundColor = .clear
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 0
    }
    public func setItemSelected(_ index: Int) {
        guard items.count >= index else {
            return
        }
        selectedItemIndex = index
    }
}
