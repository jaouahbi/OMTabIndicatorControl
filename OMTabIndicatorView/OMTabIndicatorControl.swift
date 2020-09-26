import UIKit
protocol OMTabIndicatorControlDelegate: class {
    func didSelectedItem(at index: Int)
    func willSelectedItem(at index: Int)
}
final class OMTabIndicatorControl: UIControl {
    // MARK: Init and deinit
    init(_ tabItem: [String], frame: CGRect) {
        super.init(frame: frame)
        setup(with: tabItem)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: Properties
    weak var delegate: OMTabIndicatorControlDelegate?
    private var tabItem = [String]()
    private var itemLabels = [UILabel]()
    var tabItemSpacing: CGFloat = 10
    private(set) var selectedItemIndex = 0 {
        didSet {
            selectedItem(at: selectedItemIndex)
        }
    }
    var fadePercent: CGFloat = 0.8
    var fadeGradientMask: CAGradientLayer?
    // MARK: UI
    // content view
    private let contentStackView = UIStackView()
    // selection
    var selectionMarker: UIView = UIView()
    private let selectionLine = UIView()
    var selectionLineMarkerHeight: CGFloat = 2.0
    var shearAffineTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.1, y: 1.0).shear(0.5, yShear: 0)
    // background footerLine
    private let footerLine = UIView()
    // MARK: options
    var isFaded: Bool   = true
    var showLineMarker: Bool = true
    var isGlossy: Bool = true
    var isShadowImageSelectionMarker: Bool = true
    var isAnimatable: Bool = false
    var isVertical: Bool = true
    
    // MARK: gradient base colors
    var glossGradientColor: UIColor  = .paleGreyThree
    var lineGradientColor: UIColor   = .greyishBlue
    var lineFadeGradientColor: UIColor = .paleGreyTwo
    
    // MARK: marker
    var selectionMarkerColor: UIColor = .silver
    
    // MARK: selection colors and font
    var selectedBackgroundColor: UIColor = .clear
    var selectedTextColor: UIColor    = .navyThree
    var selectedTextFont: UIFont      = UIFont.boldSystemFont(ofSize: 12)
    var selectedLineColor: UIColor    = .navyThree
    
    // MARK: unselection colors and font
    var unselectedBackgroundColor: UIColor = .clear
    var unselectedTextColor: UIColor  = .greyishBlue
    var unselectedTextFont: UIFont    = UIFont.systemFont(ofSize: 11.5, weight: .regular)
    var unselectedLineColor: UIColor  = .navyTwo
    
    var animationDuration: TimeInterval = 0.5

    var touchDownTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.2)
    var touchUpTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.7)

    // MARK: shadow
    var shadowRadius: CGFloat = 20
    var shadowEdgeMask: UInt = UInt( CGRectEdge.maxXEdge.rawValue |
                                     CGRectEdge.maxYEdge.rawValue |
                                    CGRectEdge.minXEdge.rawValue |
                                     CGRectEdge.minYEdge.rawValue)
    // MARK: Functions
    private func setup(with tabItem: [String]) {
        self.tabItem = tabItem
        itemLabels = tabItem.enumerated().map { idx, item in
            let label = UILabel()
            label.text = item
            label.font = unselectedTextFont
            label.textColor = unselectedTextColor
            label.textAlignment = .center
            label.backgroundColor = unselectedBackgroundColor
            label.isUserInteractionEnabled = true
            label.tag = idx
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTabItem))
            label.addGestureRecognizer(tapGesture)
            return label
        }
        setupStackView()
        setupSelectionView()
        selectedItemIndex = 0
        //self.backgroundColor = .clouds
    }
    private func setupStackView() {
        addSubview(contentStackView)
        contentStackView.adjustLayoutToSuperview()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fillEqually
        contentStackView.spacing = tabItemSpacing
        itemLabels.forEach { contentStackView.addArrangedSubview($0) }
    }
    var lineFadeGradientColors: [CGColor] {
        return [lineFadeGradientColor.withAlphaComponent(1.0).cgColor,
                lineFadeGradientColor.withAlphaComponent(0.0).cgColor]
    }
    var lineGradientColors: [CGColor] {
        let gradient = lineGradientColor.makeGradient()
        return gradient.map{$0.cgColor}
    }
    var glossGradientColors: [CGColor] {
        let gradient =  [glossGradientColor.withAlphaComponent(0.35),
                         glossGradientColor.withAlphaComponent(0.06)]
        return gradient.map{$0.cgColor}
    }
    private lazy var lineMarkerGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = lineGradientColors
        selectionLine.layer.insertSublayer(gradientLayer, at:0)
        return gradientLayer
    }()
    
    private lazy var lineFadeGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = lineFadeGradientColors
        footerLine.layer.insertSublayer(gradientLayer, at:0)
        return gradientLayer
    }()
    private lazy var markerGlossLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = glossGradientColors
        selectionMarker.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    private lazy var markerClipGlossLayer: OMShapeLayerClipPath = {
        let gradientLayer     = OMShapeLayerClipPath()
        markerGlossLayer.mask = gradientLayer
        return gradientLayer
    }()
    fileprivate func renderGloss() {
        markerGlossLayer.colors      = glossGradientColors
        markerGlossLayer.frame       = CGRect(origin: .zero, size:CGSize( width: selectionMarker.frame.width,
                                                                          height: selectionMarker.frame.height / 2))
        markerGlossLayer.startPoint  = CGPoint(x: selectionMarker.frame.minX, y: selectionMarker.frame.maxY)
        markerGlossLayer.endPoint    = CGPoint(x: selectionMarker.frame.minX, y: selectionMarker.frame.maxY)
        let clipRect = markerGlossLayer.bounds
        markerClipGlossLayer.path = UIBezierPath(rect: clipRect).cgPath
    }
    fileprivate func renderLineMarker() {
        lineMarkerGradientLayer.colors    = lineGradientColors
        lineMarkerGradientLayer.locations = [0.0 ,0.1, 1.0]
        lineMarkerGradientLayer.frame     = self.selectionLine.bounds
    }
    
    func renderFade() {
        lineFadeGradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0 - fadePercent)
        lineFadeGradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        lineFadeGradientLayer.frame = footerLine.bounds
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if showLineMarker {
            renderLineMarker()
        }
        if isGlossy {
            renderGloss()
        }
        if isFaded {
            renderFade()
        }
        CATransaction.commit()
    }
    private func setupSelectionView() {
        addSubview(selectionMarker)
        addSubview(selectionLine)
        addSubview(footerLine)
        selectionLine.layer.cornerRadius    = selectionLineMarkerHeight / 2
        selectionLine.layer.masksToBounds   = false
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
           selectionLine.fixedAnchorSize(width: 0, height: selectionLineMarkerHeight)

           footerLine.translatesAutoresizingMaskIntoConstraints = false
           footerLine.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
           footerLine.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
           footerLine.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
           footerLine.fixedAnchorSize(width: 0, height: selectionLineMarkerHeight)
        }
        sendSubviewToBack(selectionMarker)
        selectionMarker.backgroundColor = .clear
        sendSubviewToBack(selectionLine)
        selectionLine.layer.backgroundColor = selectedLineColor.cgColor
        sendSubviewToBack(footerLine)
        self.layoutIfNeeded()
        if isShadowImageSelectionMarker {
            let selectionMarkerHeight: CGFloat = selectionMarker.bounds.size.height - selectionLineMarkerHeight
            let selectionSize = CGSize(width: selectionMarker.bounds.size.width, height: selectionMarkerHeight)

            if let shadowImage = OMControlHelper.createShadowImage(with: selectionSize,
                                                                    shadowRadius: shadowRadius,
                                                                    shadowEdgeMask: shadowEdgeMask,
                                                                    color: selectionMarkerColor) {
                selectionMarker.backgroundColor   = UIColor(patternImage: UIImage(cgImage: shadowImage))
                selectionMarker.layer.borderColor = selectionMarkerColor.complementaryColor.cgColor
                selectionMarker.layer.borderWidth = 0.5
                selectionMarker.transform         = self.shearAffineTransform
                selectionLine.transform = selectionLine.transform.scaledBy(x: 1.1, y: 1.0)
                                                                 .translatedBy(x: -(0.05 * selectionLine.bounds.width), y: 0)
            }
        }
    }
    @objc private func didTapTabItem(_ tapGesture: UITapGestureRecognizer) {
        if let view = tapGesture.view {
            if selectedItemIndex != view.tag {
                selectedItemIndex = view.tag
                // Send UIControl valueChanged to the listeners
                sendActions(for: .valueChanged)
                delegate?.didSelectedItem(at: selectedItemIndex)
            }
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
                        self.selectionMarker.transform = self.selectionMarker.transform.concatenating(self.touchDownTransform)
                        //self.selectionLine.transform = CGAffineTransform.identity.concatenating(self.touchDownTransform)
        }, completion: { complete in
            if complete {
                UIView.animate(withDuration: 2.5,
                               delay: 0,
                               usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0.8,
                               options: [.curveLinear],  animations: {
                                self.selectionMarker.transform = self.shearAffineTransform
//                                self.selectionLine.transform   = CGAffineTransform.identity
                })
            }
        })
    }
    fileprivate func animateStepOne() {
        self.selectionMarker.layer.setAffineTransform(self.shearAffineTransform.concatenating(self.touchUpTransform))
        self.selectionLine.layer.setAffineTransform(self.selectionLine.transform.concatenating(self.touchUpTransform))
    }
    fileprivate func moveSelection(_ targetLabel: UILabel) {
        self.selectionMarker.center = CGPoint(x: targetLabel.center.x,
                                              y: self.selectionMarker.center.y)
        self.selectionLine.center   = CGPoint(x: targetLabel.center.x,
                                              y: self.selectionLine.center.y)
    }
    private func selectedItem(at index: Int) {
        // get the selection
        print("selectedItem: \(index)")
        let targetLabel = itemLabels[index]
        // targetLabel.layer.borderColor = UIColor.black.cgColor
        // targetLabel.layer.borderWidth = 2
        // notify about the selection change
        willSelecteItemAtIndex(at: index)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseIn],
                       animations: {
                if self.isAnimatable {
                    self.animateStepOne()
                }
                self.moveSelection(targetLabel)
                self.layoutIfNeeded()
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
    ////                // Move the footerLine mark
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
        label.backgroundColor = unselectedBackgroundColor
        // remove the border
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 0
    }
    public func setItemSelected(_ index: Int) {
        guard tabItem.count >= index else {
            return
        }
        selectedItemIndex = index
    }
}
