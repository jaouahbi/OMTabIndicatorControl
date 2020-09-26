import UIKit
class ViewController: UIViewController, OMTabIndicatorViewDelegate {
    func willSelectedItem(at index: Int) {
    }
    func willSelecteItemAtIndex(at index: Int) {
    }
    func didSelectedItem(at index: Int) {
        let alert = UIAlertController(title: "Selection Change",
                                      message: "\(index) selected", preferredStyle: .alert)
        present(alert, animated: true) {
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            alert.dismiss(animated: true) {
            }
        }
    }
    @IBOutlet var table: UITableView!
    let items = ["TabIndicator Item 1", "TabIndicator Item 2", "TabIndicator Item 3"]
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
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Reflect the latest size in tableHeaderView
        if self.table.shouldUpdateHeaderViewFrame() {
            // **This is where table view's content (tableHeaderView, section headers, cells)
            // frames are updated to account for the new table header size.
            self.table.beginUpdates()
            self.table.endUpdates()
        }
    }
}
