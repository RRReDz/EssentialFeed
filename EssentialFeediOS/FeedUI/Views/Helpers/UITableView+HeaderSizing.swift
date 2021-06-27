//
//  UITableView+HeaderSizing.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 27/06/21.
//

import Foundation
import UIKit

extension UITableView {
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsFrameUpdate = header.frame.height != size.height
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
