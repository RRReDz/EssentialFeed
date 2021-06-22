//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
