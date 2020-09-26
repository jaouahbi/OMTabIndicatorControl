//
//  UITableView+LayoutHeader.swift
//
//  Created by Jorge Ouahbi on 26/09/2020.
//  Copyright © 2020 Jorge Ouahbi. All rights reserved.
//

import UIKit

extension UITableView {
    func setTableHeaderView(headerView: UIView, size: CGSize) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.tableHeaderView = headerView
        // Must setup AutoLayout after set tableHeaderView.
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerView.fixedAnchorSize(width: size.width, height: size.height)
    }
    func shouldUpdateHeaderViewFrame() -> Bool {
        guard let headerView = self.tableHeaderView else { return false }
        let oldSize = headerView.bounds.size
        // Update the size
        headerView.layoutIfNeeded()
        let newSize = headerView.bounds.size
        return oldSize != newSize
    }
}
