//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 01/05/21.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
    
    func register<T: UITableViewCell>(cellType: T.Type) {
        let identifier = String(describing: cellType)
        register(cellType, forCellReuseIdentifier: identifier)
    }
}
