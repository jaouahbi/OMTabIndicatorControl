import UIKit
class ViewController: UIViewController, OMTabIndicatorViewDelegate {
    func didSelectItem(at index: Int) {
        let alert = UIAlertController(title: "Selection Change",
                                      message: "\(index) selected", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            alert.addAction(action)
            alert.dismiss(animated: true) {
                
            }
        }
        present(alert, animated: true) {
            
        }
    }
    
    @IBOutlet var table: UITableView!
    let items = ["Composición", "Últimos Movimientos"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    var headerHeight: CGFloat = 35
    var estimatedSegmentedControlFrame: CGRect {
        return CGRect(x: 0,
                      y: 0,
                      width: self.table.bounds.width,
                      height: headerHeight)
    }
    var tabIndicator: OMTabIndicatorView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabIndicator = OMTabIndicatorView(items, frame: estimatedSegmentedControlFrame)
        tabIndicator.frame = estimatedSegmentedControlFrame
        table.estimatedSectionHeaderHeight = headerHeight
        table.sectionHeaderHeight = headerHeight
        tabIndicator.delegate = self
        self.table.setTableHeaderView(headerView: tabIndicator, size: estimatedSegmentedControlFrame.size)
        view.setNeedsLayout()
        
        //        tabIndicator.translatesAutoresizingMaskIntoConstraints = false
        //        tabIndicator.trailingAnchor.constraint(equalTo: table.trailingAnchor, constant: 0).isActive = true
        //        tabIndicator.leadingAnchor.constraint(equalTo: table.leadingAnchor, constant: 0).isActive = true
        //        tabIndicator.topAnchor.constraint(equalTo: table.topAnchor, constant: 0).isActive = true
        //        //view.bottomAnchor.constraint(equalTo: tabIndicator.bottomAnchor, constant: 0).isActive = true
        //        tabIndicator.topAnchor.constraint(equalTo: table.safeAreaLayoutGuide.topAnchor).isActive = true
        //        tabIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 2. Reflect the latest size in tableHeaderView
        if self.table.shouldUpdateHeaderViewFrame() {
            // **This is where table view's content (tableHeaderView, section headers, cells)
            // frames are updated to account for the new table header size.
            self.table.beginUpdates()
            self.table.endUpdates()
        }
    }
}
