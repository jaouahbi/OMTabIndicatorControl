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
    func didSelectItem(at index: Int)
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
    var selectionMarkerView: UIView = UIView()
    private let lineView = UIView()
    var unselectedTextColor: UIColor {
        return selectedTextColor.complementaryColor
    }
    var selectedTextColor: UIColor  = UIColor.blue.lighter
    var markerGradientColor: UIColor = .darkClouds
    var lineGradientColor: UIColor = UIColor.blue.darker
    var selectedLineColor: UIColor  = UIColor.blue.withAlphaComponent(0.8)
    var markerColor: CGColor = UIColor.silver.withAlphaComponent(0.7).cgColor
    //var lineColor: CGColor = UIColor.navyTwo.withAlphaComponent(0.7).cgColor
    var selectedTextFont: UIFont = UIFont.boldSystemFont(ofSize: 13)
    var unselectedTextFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .light)
    var animationDuration: TimeInterval = 0.5
    
    var touchDownTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.2)
    var touchUpTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.7)
    var lineMarkHeight: CGFloat = 2
    
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
    }
    private func configureStackView() {
        addSubview(contentStackView)
        contentStackView.adjustLayoutToSuperview()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fillEqually
        itemLabels.forEach { contentStackView.addArrangedSubview($0) }
    }
    var markerGradientColors: [CGColor] {
        return markerGradientColor.makeGradient().enumerated().map{$1.withAlphaComponent($0 == 0 ? 1.0 : 0.1).cgColor}
    }
    var lineGradientColors: [CGColor] {
        let gradient = lineGradientColor.makeGradient()
        return gradient.enumerated().map{$1.withAlphaComponent($0 == 0 ? 0.1 : 1.0).cgColor}
    }
    private lazy var markerGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = isVertical ? CGPoint(x: 0.5, y: 0.0) : CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = isVertical ? CGPoint(x: 0.5, y: 1.0) : CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors     = markerGradientColors.map({UIColor(cgColor: $0).complementaryColor.lighter.cgColor})
        selectionMarkerView.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    private lazy var lineMarkerGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = isVertical ? CGPoint(x: 0.5, y: 0.0) : CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = isVertical ? CGPoint(x: 0.5, y: 1.0) : CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = lineGradientColors.map({UIColor(cgColor: $0).complementaryColor.lighter.cgColor})
        lineView.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    var isAnimatable: Bool = false
    var isVertical: Bool = true
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        markerGradientLayer.colors    = markerGradientColors
        markerGradientLayer.locations = [0.0 ,0.9, 1.0]
        markerGradientLayer.frame     = self.selectionMarkerView.bounds
        
        lineMarkerGradientLayer.colors = lineGradientColors
        lineMarkerGradientLayer.locations = [0.0 ,0.9, 1.0]
        lineMarkerGradientLayer.frame = self.lineView.bounds
        CATransaction.commit()
    }
    var swearTransform: CGAffineTransform = shearTransform(CGAffineTransform(scaleX: 1.1, y: 1), x: 0.5, y: 0)
    var tabSelectionLeftAnchor: NSLayoutConstraint!
    var tabSelectionRightAnchor: NSLayoutConstraint!
    private func setupSelectionView() {
        addSubview(selectionMarkerView)
        addSubview(lineView)
        lineView.layer.cornerRadius    = 1
        lineView.layer.masksToBounds   = false
        selectionMarkerView.isHidden = true
        if let itemLabel = itemLabels.first {
            
            selectionMarkerView.translatesAutoresizingMaskIntoConstraints = false
            selectionMarkerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            selectionMarkerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            itemLabel.leftAnchor.constraint(equalTo: selectionMarkerView.leftAnchor, constant: 0).isActive  = true
            itemLabel.rightAnchor.constraint(equalTo: selectionMarkerView.rightAnchor, constant: 0).isActive  = true
            
            
            lineView.translatesAutoresizingMaskIntoConstraints = false
            lineView.leftAnchor.constraint(equalTo: selectionMarkerView.leftAnchor, constant: 0).isActive = true
            lineView.rightAnchor.constraint(equalTo: selectionMarkerView.rightAnchor, constant: 0).isActive = true
            //lineView.topAnchor.constraint(equalTo: itemLabel.topAnchor, constant: 0).isActive = false
            lineView.bottomAnchor.constraint(equalTo: selectionMarkerView.bottomAnchor, constant: 0).isActive = true
            lineView.fixedAnchorSize(width: selectionMarkerView.bounds.width, height: lineMarkHeight)
            
        }
        sendSubviewToBack(selectionMarkerView)
        //selectionMarkerView.layer.backgroundColor = markerColor
        sendSubviewToBack(lineView)
        //lineView.layer.backgroundColor = selectedLineColor.cgColor
        
        self.layoutIfNeeded()
        
        let markHeight: CGFloat = selectionMarkerView.bounds.size.height - lineMarkHeight
        let selectionSize = CGSize(width: selectionMarkerView.bounds.size.width, height: markHeight)
        let shadowEdgeMask: UInt = UInt( CGRectEdge.maxXEdge.rawValue |
                                         CGRectEdge.maxYEdge.rawValue |
                                         CGRectEdge.minXEdge.rawValue)
        
        if let shadowImage = UIControlHelper.createShadowImageWithSize(size: selectionSize,
                                                                       shadowRadius: 20,
                                                                       shadowEdgeMask: shadowEdgeMask,
                                                                       color: UIColor(cgColor: markerColor)) {
            selectionMarkerView.backgroundColor = UIColor(patternImage: UIImage(cgImage: shadowImage))
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
            delegate?.didSelectItem(at: selectedItemIndex)
        }
    }
    func willSelecteItemAtIndex( at index: Int) {
        itemLabels.forEach(resetFontOnLabel)
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
                        self.selectionMarkerView.transform = CGAffineTransform.identity.concatenating(self.touchDownTransform)
                        self.lineView.transform = CGAffineTransform.identity.concatenating(self.touchDownTransform)
        }, completion: { complete in
            if complete {
                UIView.animate(withDuration: 2.5,
                               delay: 0,
                               usingSpringWithDamping: 0.9,
                               initialSpringVelocity: 0.8,
                               options: [.curveLinear],  animations: {
                                self.selectionMarkerView.transform = CGAffineTransform.identity
                                self.lineView.transform = CGAffineTransform.identity
                })
                
            }
        })
    }
    
    private func selectedItem(at index: Int) {
        // get the selection
        print("selectedItem: \(index)")
        layoutIfNeeded()
        let targetLabel = itemLabels[index]
        // notify about the selection change
        willSelecteItemAtIndex(at: index)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseIn],
                       animations: {
                        if self.isAnimatable {
                            self.selectionMarkerView.layer.setAffineTransform(self.swearTransform.concatenating(self.touchUpTransform))
                            self.lineView.layer.setAffineTransform(self.lineView.transform.concatenating(self.touchUpTransform))
                        }
                        self.selectionMarkerView.center = CGPoint(x: targetLabel.center.x,
                                                                  y: self.selectionMarkerView.center.y)
                        self.lineView.center = CGPoint(x: targetLabel.center.x,
                                                       y: self.lineView.center.y)
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
    private func resetFontOnLabel(_ label: UILabel) {
        label.font = unselectedTextFont
        label.textColor = unselectedTextColor
        label.backgroundColor = .clear
    }
    public func setItemSelected(_ index: Int) {
        guard items.count >= index else {
            return
        }
        selectedItemIndex = index
    }
}
